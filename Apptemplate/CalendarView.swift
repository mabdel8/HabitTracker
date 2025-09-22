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
    @State private var viewMode: CalendarViewMode = .yearly
    
    enum CalendarViewMode {
        case yearly, monthly
    }
    
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
                LazyVStack(spacing: 4) {
                    viewToggleCard
                    
                    if habitManager.habits.isEmpty {
                        emptyStateCard
                    } else {
                        if viewMode == .monthly {
                            monthNavigationCard
                        }
                        
                        ForEach(habitManager.habits, id: \.id) { habit in
                            habitCard(for: habit)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
            }
            .navigationTitle("Calendar")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - View Toggle Card
    private var viewToggleCard: some View {
        VStack {
            HStack {
                Text("View")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Picker("View Mode", selection: $viewMode) {
                    Text("Yearly").tag(CalendarViewMode.yearly)
                    Text("Monthly").tag(CalendarViewMode.monthly)
                }
                .pickerStyle(.segmented)
                .frame(width: 150)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
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
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Habit Card
    private func habitCard(for habit: Habit) -> some View {
        VStack(spacing: 4) {
            // Habit header - minimal
            HStack(spacing: 8) {
                Image(systemName: habit.icon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: habit.color) ?? .blue)
                    .frame(width: 24, height: 24)
                
                Text(habit.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            
            // Graph content based on view mode
            if viewMode == .yearly {
                ContributionGraph(habit: habit)
                    .padding(.horizontal, 8)
            } else {
                CalendarHeatmap(habit: habit, month: currentMonth)
                    .padding(.horizontal, 8)
            }
            
            Spacer().frame(height: 2)
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
                    // Show all 7 days for current week, past days for other weeks
                    let isCurrentWeek = calendar.isDate(date, equalTo: today, toGranularity: .weekOfYear)
                    if date <= today || isCurrentWeek {
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
                HStack(spacing: 1) {
                    ForEach(Array(weeksData.enumerated()), id: \.offset) { weekIndex, week in
                        VStack(spacing: 1) {
                            ForEach(0..<7, id: \.self) { dayIndex in
                                if let date = week[dayIndex] {
                                    ContributionSquare(habit: habit, date: date, color: habitColor)
                                } else {
                                    Rectangle()
                                        .fill(Color.clear)
                                        .frame(width: 6, height: 6)
                                }
                            }
                        }
                        .id("week_\(weekIndex)")
                    }
                }
                .padding(.horizontal, 6) // Minimal padding
            }
            .clipped() // Prevent overflow outside bounds
            .onAppear {
                // Instantly position at current week
                if !weeksData.isEmpty {
                    let targetWeek = max(0, weeksData.count - 8)
                    DispatchQueue.main.async {
                        scrollProxy.scrollTo("week_\(targetWeek)", anchor: .leading)
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
            .frame(width: 6, height: 6)
            .cornerRadius(1)
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