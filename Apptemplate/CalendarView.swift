//
//  CalendarView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct CalendarView: View {
    @EnvironmentObject var habitManager: HabitManager
    @State private var selectedDate = Date()
    @State private var selectedHabit: Habit?
    @State private var showingHabitSelector = false
    
    private var currentMonth: Date {
        Calendar.current.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
    }
    
    private var monthDisplayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthNavigationSection
                    
                    if habitManager.habits.isEmpty {
                        emptyStateView
                    } else {
                        habitSelectorSection
                        
                        if let selectedHabit = selectedHabit {
                            calendarHeatmapSection(for: selectedHabit)
                            contributionGraphSection(for: selectedHabit)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Calendar")
        }
        .onAppear {
            if selectedHabit == nil && !habitManager.habits.isEmpty {
                selectedHabit = habitManager.habits.first
            }
        }
        .onChange(of: habitManager.habits) { _, newHabits in
            if selectedHabit == nil && !newHabits.isEmpty {
                selectedHabit = newHabits.first
            } else if let selected = selectedHabit, !newHabits.contains(where: { $0.id == selected.id }) {
                selectedHabit = newHabits.first
            }
        }
    }
    
    private var monthNavigationSection: some View {
        HStack {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            
            Spacer()
            
            Text(monthDisplayText)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var habitSelectorSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(habitManager.habits, id: \.id) { habit in
                    HabitSelectorCard(
                        habit: habit,
                        isSelected: selectedHabit?.id == habit.id
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedHabit = habit
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func calendarHeatmapSection(for habit: Habit) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monthly Progress")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(monthCompletedDays(for: habit))/\(monthTotalDays) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            CalendarHeatmap(habit: habit, month: currentMonth)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func contributionGraphSection(for habit: Habit) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("Contribution Graph")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("Past 365 days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ContributionGraph(habit: habit)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Habits to View")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Add some habits to see your calendar progress")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 60)
    }
    
    private var monthTotalDays: Int {
        Calendar.current.range(of: .day, in: .month, for: currentMonth)?.count ?? 0
    }
    
    private func monthCompletedDays(for habit: Habit) -> Int {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let range = calendar.range(of: .day, in: .month, for: currentMonth) else {
            return 0
        }
        
        var completedDays = 0
        for day in 1...range.count {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) else { continue }
            
            if let entry = habit.entries.first(where: { calendar.isDate($0.date, inSameDayAs: date) }),
               entry.count >= habit.targetCount {
                completedDays += 1
            }
        }
        
        return completedDays
    }
}

struct HabitSelectorCard: View {
    let habit: Habit
    let isSelected: Bool
    let action: () -> Void
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: habit.icon)
                    .font(.headline)
                    .foregroundStyle(isSelected ? .white : habitColor)
                
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? habitColor : Color(.systemGray6))
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CalendarHeatmap: View {
    let habit: Habit
    let month: Date
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    private var monthDates: [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
              let range = calendar.range(of: .day, in: .month, for: month) else {
            return []
        }
        
        var dates: [Date] = []
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                // Empty cells for month start offset
                ForEach(0..<startOffset, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 32)
                }
                
                // Month dates
                ForEach(monthDates, id: \.self) { date in
                    CalendarDayCell(habit: habit, date: date, color: habitColor)
                }
            }
        }
    }
    
    private var startOffset: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: month)
        return weekday - 1
    }
}

struct CalendarDayCell: View {
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
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var isFuture: Bool {
        date > Date()
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(cellBackgroundColor)
                .frame(height: 32)
                .cornerRadius(6)
            
            if !isFuture {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundStyle(textColor)
            } else {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var cellBackgroundColor: Color {
        if isFuture {
            return Color(.systemGray6)
        } else if progress == 0 {
            return Color(.systemGray6)
        } else {
            return color.opacity(0.2 + (progress * 0.8))
        }
    }
    
    private var textColor: Color {
        if isFuture {
            return .secondary
        } else if progress > 0.5 {
            return .white
        } else {
            return .primary
        }
    }
}

struct ContributionGraph: View {
    let habit: Habit
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    // Generate past 365 days
    private var yearDates: [Date] {
        let calendar = Calendar.current
        var dates: [Date] = []
        
        for i in 0..<365 {
            if let date = calendar.date(byAdding: .day, value: -i, to: Date()) {
                dates.append(date)
            }
        }
        
        return dates.reversed()
    }
    
    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 2), count: 53)
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(yearDates, id: \.self) { date in
                    ContributionSquare(habit: habit, date: date, color: habitColor)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ContributionSquare: View {
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
    
    private var isFuture: Bool {
        date > Date()
    }
    
    var body: some View {
        Rectangle()
            .fill(squareColor)
            .frame(width: 12, height: 12)
            .cornerRadius(2)
    }
    
    private var squareColor: Color {
        if isFuture {
            return Color(.systemGray6)
        } else if progress == 0 {
            return Color(.systemGray6)
        } else {
            return color.opacity(0.2 + (progress * 0.8))
        }
    }
}

#Preview {
    CalendarView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
}