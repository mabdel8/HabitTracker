//
//  WeeklyView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct WeeklyView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var selectedWeek = Date()
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: selectedWeek) else {
            return []
        }
        
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private var weekDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        guard let firstDay = weekDates.first,
              let lastDay = weekDates.last else {
            return ""
        }
        
        let calendar = Calendar.current
        if calendar.isDate(firstDay, equalTo: lastDay, toGranularity: .month) {
            return "\(formatter.string(from: firstDay)) - \(calendar.component(.day, from: lastDay))"
        } else {
            return "\(formatter.string(from: firstDay)) - \(formatter.string(from: lastDay))"
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    weekNavigationSection
                    
                    if habitManager.habits.isEmpty {
                        emptyStateView
                    } else {
                        weeklyGridSection
                    }
                }
                .padding(16)
            }
            .navigationTitle("Weekly")
        }
    }
    
    private var weekNavigationSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedWeek) ?? selectedWeek
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                Text(weekDisplayText)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedWeek) ?? selectedWeek
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            
            // Week days header
            HStack {
                ForEach(weekDates, id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(dayAbbreviation(for: date))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("\(Calendar.current.component(.day, from: date))")
                            .font(.headline)
                            .fontWeight(Calendar.current.isDateInToday(date) ? .bold : .medium)
                            .foregroundStyle(Calendar.current.isDateInToday(date) ? .blue : .primary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var weeklyGridSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(habitManager.habits, id: \.id) { habit in
                WeeklyHabitRow(habit: habit, weekDates: weekDates)
                    .environmentObject(habitManager)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Habits to Track")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some habits to see your weekly progress")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
    
    private func dayAbbreviation(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct WeeklyHabitRow: View {
    let habit: Habit
    let weekDates: [Date]
    @EnvironmentObject var habitManager: HabitManager
    
    private var progressColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Habit header
            HStack(spacing: 14) {
                // Icon in tinted circle
                ZStack {
                    Circle()
                        .fill(progressColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: habit.icon)
                        .font(.title3)
                        .foregroundStyle(progressColor)
                }
                
                Text(habit.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(weekCompletedDays)/7 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Progress dots
            HStack(spacing: 8) {
                ForEach(weekDates, id: \.self) { date in
                    WeeklyProgressDot(
                        habit: habit,
                        date: date,
                        color: progressColor
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
    }
    
    private var weekCompletedDays: Int {
        weekDates.filter { date in
            if let entry = habit.entries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                return entry.count >= habit.targetCount
            }
            return false
        }.count
    }
}

struct WeeklyProgressDot: View {
    let habit: Habit
    let date: Date
    let color: Color
    
    private var entry: HabitEntry? {
        habit.entries.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    private var progress: Double {
        guard let entry = entry else { return 0.0 }
        return min(Double(entry.count) / Double(habit.targetCount), 1.0)
    }
    
    private var isCompleted: Bool {
        (entry?.count ?? 0) >= habit.targetCount
    }
    
    private var isFuture: Bool {
        date > Date()
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Background circle
                Circle()
                    .fill(isCompleted ? color : Color(.systemGray6))
                    .frame(width: 36, height: 36)
                
                // Progress circle
                if !isFuture {
                    if !isCompleted {
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 36, height: 36)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    // Completion indicator
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    } else if progress > 0 {
                        Text("\(entry?.count ?? 0)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(color)
                    }
                } else {
                    // Future date indicator
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 20, height: 20)
                }
            }
        }
    }
}

#Preview {
    WeeklyView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
}