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
                LazyVStack(spacing: 16) {
                    monthNavigationCard
                    
                    if habitManager.habits.isEmpty {
                        emptyStateCard
                    } else {
                        habitSelectorCard
                        
                        if let selectedHabit = selectedHabit {
                            calendarHeatmapCard(for: selectedHabit)
                            contributionGraphCard(for: selectedHabit)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .navigationTitle("Calendar")
            .background(Color(.systemGroupedBackground))
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
    
    // MARK: - Month Navigation Card
    private var monthNavigationCard: some View {
        VStack {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthDisplayText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .frame(width: 44, height: 44)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Habit Selector Card
    private var habitSelectorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Habit")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(habitManager.habits.count) habit\(habitManager.habits.count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
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
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Calendar Heatmap Card
    private func calendarHeatmapCard(for habit: Habit) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Progress")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("Daily habit completion this month")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(monthCompletedDays(for: habit))/\(monthTotalDays)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    Text("days completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            CalendarHeatmap(habit: habit, month: currentMonth)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Contribution Graph Card
    private func contributionGraphCard(for habit: Habit) -> some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Contribution Graph")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("GitHub-style activity overview")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Past Year")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                    
                    Text("365 days")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            
            ContributionGraph(habit: habit)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Empty State Card
    private var emptyStateCard: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 12) {
                Text("No Habits to View")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text("Add some habits to see your calendar progress and contribution graphs")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helper Functions
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

// MARK: - Habit Selector Card Component
struct HabitSelectorCard: View {
    let habit: Habit
    let isSelected: Bool
    let action: () -> Void
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: habit.icon)
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : habitColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(isSelected ? .white : .primary)
                        .lineLimit(1)
                    
                    Text("\(habit.targetCount) \(habit.unit)")
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? habitColor : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Calendar Heatmap Component
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
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(spacing: 12) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
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
                        .frame(height: 36)
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

// MARK: - Calendar Day Cell Component
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
            RoundedRectangle(cornerRadius: 8)
                .fill(cellBackgroundColor)
                .frame(height: 36)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(isToday ? color : Color.clear, lineWidth: 2)
                )
            
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption)
                .fontWeight(isToday ? .bold : .medium)
                .foregroundStyle(textColor)
        }
    }
    
    private var cellBackgroundColor: Color {
        if isFuture {
            return Color(.systemGray6)
        } else if progress == 0 {
            return Color(.systemGray6)
        } else {
            return color.opacity(0.2 + (progress * 0.6))
        }
    }
    
    private var textColor: Color {
        if isFuture {
            return .secondary
        } else if progress > 0.6 {
            return .white
        } else {
            return .primary
        }
    }
}

// MARK: - Contribution Graph Component
struct ContributionGraph: View {
    let habit: Habit
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    // Generate organized weeks data for past 52 weeks
    private var weeksData: [[Date?]] {
        let calendar = Calendar.current
        let today = Date()
        var weeks: [[Date?]] = []
        
        // Start from today and go back 52 weeks
        guard let startDate = calendar.date(byAdding: .weekOfYear, value: -51, to: today) else {
            return []
        }
        
        // Find the start of the week for the start date
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start else {
            return []
        }
        
        // Generate 52 weeks of data
        for weekOffset in 0..<52 {
            guard let weekDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: weekStart) else {
                continue
            }
            
            var week: [Date?] = []
            
            // Generate 7 days for this week (Sunday = 0 to Saturday = 6)
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekDate) {
                    // Only include dates up to today
                    if date <= today {
                        week.append(date)
                    } else {
                        week.append(nil)
                    }
                } else {
                    week.append(nil)
                }
            }
            
            weeks.append(week)
        }
        
        return weeks
    }
    
    var body: some View {
        // Just the scrollable contribution grid - no labels
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 3) {
                    ForEach(Array(weeksData.enumerated()), id: \.offset) { weekIndex, week in
                        VStack(spacing: 3) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                if let date = week[dayIndex] {
                                    ContributionSquare(habit: habit, date: date, color: habitColor)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 12, height: 12)
                                }
                            }
                        }
                        .id("week_\(weekIndex)")
                    }
                }
                .padding(.horizontal, 12) // Padding to prevent cutoff
            }
            .clipped() // Prevent overflow outside bounds
            .onAppear {
                // Scroll to show the current week on the right side
                if !weeksData.isEmpty {
                    let targetWeek = max(0, weeksData.count - 6) // Show last 6 weeks visible
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            scrollProxy.scrollTo("week_\(targetWeek)", anchor: .leading)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Contribution Square Component
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
            return color.opacity(0.2 + (progress * 0.6))
        }
    }
}


#Preview {
    CalendarView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
}