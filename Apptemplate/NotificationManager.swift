//
//  NotificationManager.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import Foundation
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    @Published var hasPermission = false
    
    static let shared = NotificationManager()
    
    private init() {
        checkNotificationPermission()
    }
    
    // MARK: - Permission Management
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            hasPermission = granted
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            hasPermission = false
            return false
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Habit Reminder Scheduling
    
    func scheduleHabitReminder(for habit: Habit) {
        guard hasPermission else { return }
        
        // Remove existing notifications for this habit
        cancelHabitReminder(for: habit)
        
        // Schedule new notifications based on reminder settings
        if let reminderTime = habit.reminderTime {
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            for day in habit.reminderDays {
                let content = UNMutableNotificationContent()
                content.title = "Time to \(habit.name)"
                content.body = "Don't forget your daily habit!"
                content.sound = .default
                content.categoryIdentifier = "HABIT_REMINDER"
                
                // Create date components for the specific day and time
                var dateComponents = DateComponents()
                dateComponents.weekday = day.rawValue
                dateComponents.hour = timeComponents.hour
                dateComponents.minute = timeComponents.minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let identifier = "habit_\(habit.id.uuidString)_day_\(day.rawValue)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Failed to schedule notification: \(error)")
                    }
                }
            }
        }
    }
    
    func cancelHabitReminder(for habit: Habit) {
        let identifiers = Weekday.allCases.map { "habit_\(habit.id.uuidString)_day_\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func updateHabitReminder(for habit: Habit) {
        if habit.reminderEnabled {
            scheduleHabitReminder(for: habit)
        } else {
            cancelHabitReminder(for: habit)
        }
    }
    
    // MARK: - Helper Methods
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Weekday Enum

enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var shortName: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}