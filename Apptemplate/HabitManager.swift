//
//  HabitManager.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import Foundation
import SwiftData
import TipKit

@MainActor
class HabitManager: ObservableObject {
    var modelContext: ModelContext
    
    @Published var habits: [Habit] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadHabits()
    }
    
    // MARK: - Data Loading
    
    func loadHabits() {
        do {
            let descriptor = FetchDescriptor<Habit>(
                predicate: #Predicate<Habit> { !$0.isArchived },
                sortBy: [SortDescriptor(\.sortOrder), SortDescriptor(\.createdAt)]
            )
            habits = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load habits: \(error)")
            habits = []
        }
    }
    
    // MARK: - Habit Management
    
    func addHabit(_ habit: Habit) {
        let wasEmpty = habits.isEmpty
        habit.sortOrder = habits.count
        modelContext.insert(habit)
        saveContext()
        loadHabits()
        
        // Trigger tip when first habit is added
        if wasEmpty && !habits.isEmpty {
            HabitLoggingTip.hasAddedFirstHabit = true
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        habit.isArchived = true
        saveContext()
        loadHabits()
    }
    
    func updateHabit(_ habit: Habit) {
        saveContext()
        loadHabits()
    }
    
    // MARK: - Entry Management
    
    func incrementHabit(_ habit: Habit, date: Date = Date()) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let existingEntry = habit.entries.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) 
        }) {
            existingEntry.count += 1
        } else {
            let newEntry = HabitEntry(date: normalizedDate, count: 1, habit: habit)
            modelContext.insert(newEntry)
            habit.entries.append(newEntry)
        }
        
        saveContext()
        objectWillChange.send()
    }
    
    func decrementHabit(_ habit: Habit, date: Date = Date()) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let existingEntry = habit.entries.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) 
        }) {
            existingEntry.count = max(0, existingEntry.count - 1)
            saveContext()
            objectWillChange.send()
        }
    }
    
    func setHabitCount(_ habit: Habit, count: Int, date: Date = Date()) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        if let existingEntry = habit.entries.first(where: { 
            Calendar.current.isDate($0.date, inSameDayAs: normalizedDate) 
        }) {
            existingEntry.count = max(0, count)
        } else if count > 0 {
            let newEntry = HabitEntry(date: normalizedDate, count: count, habit: habit)
            modelContext.insert(newEntry)
            habit.entries.append(newEntry)
        }
        
        saveContext()
        objectWillChange.send()
    }
    
    // MARK: - Progress Calculation
    
    func getWeeklyProgress(for habit: Habit, startDate: Date) -> [Double] {
        let calendar = Calendar.current
        var progress: [Double] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else {
                progress.append(0.0)
                continue
            }
            
            let dayStart = calendar.startOfDay(for: date)
            let entry = habit.entries.first { calendar.isDate($0.date, inSameDayAs: dayStart) }
            let dayProgress = entry?.count ?? 0
            progress.append(min(Double(dayProgress) / Double(habit.targetCount), 1.0))
        }
        
        return progress
    }
    
    func getMonthlyProgress(for habit: Habit, month: Date) -> [Double] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let monthRange = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }
        
        var progress: [Double] = []
        
        for day in 1...monthRange.count {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) else {
                progress.append(0.0)
                continue
            }
            
            let entry = habit.entries.first { calendar.isDate($0.date, inSameDayAs: date) }
            let dayProgress = entry?.count ?? 0
            progress.append(min(Double(dayProgress) / Double(habit.targetCount), 1.0))
        }
        
        return progress
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}

// MARK: - Predefined Habit Templates

struct HabitTemplate {
    let name: String
    let icon: String
    let color: String
    let targetCount: Int
    let unit: String
    
    func createHabit(customTarget: Int? = nil, reminderEnabled: Bool = false, reminderTime: Date? = nil, reminderDays: [Weekday] = []) -> Habit {
        return Habit(
            name: name,
            icon: icon,
            color: color,
            targetCount: customTarget ?? targetCount,
            unit: unit,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderTime,
            reminderDays: reminderDays
        )
    }
}

extension HabitManager {
    static let predefinedTemplates = [
        HabitTemplate(name: "Drink Water", icon: "drop.fill", color: "#007AFF", targetCount: 80, unit: "oz"),
        HabitTemplate(name: "Exercise", icon: "figure.run", color: "#FF3B30", targetCount: 1, unit: "session"),
        HabitTemplate(name: "Read", icon: "book.fill", color: "#FF9500", targetCount: 30, unit: "minutes"),
        HabitTemplate(name: "Meditate", icon: "brain.head.profile", color: "#AF52DE", targetCount: 10, unit: "minutes"),
        HabitTemplate(name: "Walk", icon: "figure.walk", color: "#34C759", targetCount: 10000, unit: "steps"),
        HabitTemplate(name: "Sleep Early", icon: "bed.double.fill", color: "#5856D6", targetCount: 1, unit: "night"),
        HabitTemplate(name: "Journal", icon: "pencil", color: "#FF2D92", targetCount: 1, unit: "entry"),
        HabitTemplate(name: "Stretch", icon: "figure.flexibility", color: "#32D74B", targetCount: 1, unit: "session")
    ]
}