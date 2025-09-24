//
//  Habit.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var id: UUID
    var name: String
    var icon: String           // SF Symbol name
    var color: String          // Hex color for personalization
    var targetCount: Int       // Daily target (e.g., 1 for binary habits, 8 for water glasses)
    var unit: String           // "times", "glasses", "minutes", etc.
    var createdAt: Date
    var isArchived: Bool
    var sortOrder: Int         // For custom ordering
    
    // Reminder properties
    var reminderEnabled: Bool
    var reminderTime: Date?
    var reminderDays: [Weekday]
    
    // Relationships
    @Relationship(deleteRule: .cascade) var entries: [HabitEntry]
    
    init(name: String, icon: String, color: String, targetCount: Int, unit: String, sortOrder: Int = 0, reminderEnabled: Bool = false, reminderTime: Date? = nil, reminderDays: [Weekday] = []) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color
        self.targetCount = targetCount
        self.unit = unit
        self.createdAt = Date()
        self.isArchived = false
        self.sortOrder = sortOrder
        self.reminderEnabled = reminderEnabled
        self.reminderTime = reminderTime
        self.reminderDays = reminderDays
        self.entries = []
    }
    
    // Computed properties for progress tracking
    var todayEntry: HabitEntry? {
        let today = Calendar.current.startOfDay(for: Date())
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    var todayProgress: Double {
        guard let todayEntry = todayEntry else { return 0.0 }
        return min(Double(todayEntry.count) / Double(targetCount), 1.0)
    }
    
    var todayCount: Int {
        todayEntry?.count ?? 0
    }
    
    var isCompletedToday: Bool {
        todayCount >= targetCount
    }
}

@Model
final class HabitEntry {
    var id: UUID
    var date: Date             // Normalized to start of day
    var count: Int             // How many times completed that day
    var createdAt: Date
    
    // Relationships
    var habit: Habit?
    
    init(date: Date, count: Int, habit: Habit? = nil) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.count = count
        self.createdAt = Date()
        self.habit = habit
    }
}
