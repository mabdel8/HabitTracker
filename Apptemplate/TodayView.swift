//
//  TodayView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData
import TipKit

struct TodayView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingHabitCreation = false
    
    private var completedCount: Int {
        habitManager.habits.filter(\.isCompletedToday).count
    }
    
    private var totalCount: Int {
        habitManager.habits.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    
                    if habitManager.habits.isEmpty {
                        emptyStateView
                    } else {
                        habitsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Today")
        }
        .overlay(
            // Floating Action Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showingHabitCreation = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
                            )
                    }
                    .scaleEffect(showingHabitCreation ? 0.9 : 1.0)
                    .animation(.spring(response: 0.3), value: showingHabitCreation)
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        )
        .sheet(isPresented: $showingHabitCreation) {
            HabitCreationView()
                .environmentObject(habitManager)
                .environmentObject(storeManager)
        }
        .refreshable {
            habitManager.loadHabits()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(Date(), style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundStyle(.primary)
                        
                        Text("Your Progress")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }
                }
                
                Spacer()
                
                if totalCount > 0 {
                    VStack(spacing: 4) {
                        Text("\(completedCount)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                            .animation(.easeInOut(duration: 0.3), value: completedCount)
                        
                        Text("of \(totalCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            if totalCount > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    
                    ProgressView(value: Double(completedCount), total: Double(totalCount))
                        .progressViewStyle(LinearProgressViewStyle(tint: .green))
                    
                    Text("\(Int((Double(completedCount) / Double(totalCount)) * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .frame(minWidth: 40)
                }
            }
        }
        .padding(20)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("No Habits Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Start building better habits by adding your first one")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                showingHabitCreation = true
            }) {
                Text("Add Your First Habit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
        }
        .padding(.top, 60)
    }
    
    private var habitsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(habitManager.habits, id: \.id) { habit in
                HabitRowView(habit: habit)
                    .environmentObject(habitManager)
                    .popoverTip(HabitLoggingTip(), arrowEdge: .bottom)
                    .onAppear {
                        // Trigger the tip parameter for the first habit
                        if habit == habitManager.habits.first {
                            HabitLoggingTip.hasAddedFirstHabit = true
                        }
                    }
            }
        }
    }
}

// MARK: - Habit Logging Sheet
struct HabitLoggingSheet: View {
    let habit: Habit
    @Binding var inputValue: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isInputFocused: Bool
    
    private var progressColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Habit info header
                VStack(spacing: 12) {
                    Image(systemName: habit.icon)
                        .font(.system(size: 40))
                        .foregroundStyle(progressColor)
                    
                    Text(habit.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Goal: \(habit.targetCount) \(habit.unit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                // Input section
                VStack(spacing: 16) {
                    Text("Enter \(habit.unit)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    TextField("0", text: $inputValue)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(progressColor)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .focused($isInputFocused)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .frame(maxWidth: 200)
                }
                
                
                Spacer()
                
                // Save button
                Button(action: {
                    onSave(inputValue)
                    dismiss()
                }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(progressColor)
                        .cornerRadius(16)
                }
                .disabled(inputValue.isEmpty || Int(inputValue) == nil)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Log Progress")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            isInputFocused = true
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    @EnvironmentObject var habitManager: HabitManager
    @State private var showCompletionAnimation = false
    @State private var showLoggingSheet = false
    @State private var inputValue = ""
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    private var progressColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        ZStack {
            // Background swipe feedback indicators
            HStack {
                // Left side feedback
                if isDragging && dragOffset.width > 50 {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(progressColor)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(progressColor.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(progressColor.opacity(0.3))
                            .frame(width: 4, height: 4)
                    }
                    .opacity(min(dragOffset.width / 100.0, 1.0))
                    .transition(.opacity)
                }
                
                Spacer()
                
                // Right side feedback  
                if isDragging && dragOffset.width < -50 {
                    VStack(spacing: 2) {
                        Circle()
                            .fill(progressColor.opacity(0.3))
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(progressColor.opacity(0.6))
                            .frame(width: 6, height: 6)
                        Circle()
                            .fill(progressColor)
                            .frame(width: 8, height: 8)
                    }
                    .opacity(min(abs(dragOffset.width) / 100.0, 1.0))
                    .transition(.opacity)
                }
            }
            .padding(.horizontal, 8)
            
            // Main habit card content
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: habit.icon)
                        .font(.title2)
                        .foregroundStyle(progressColor)
                        .frame(width: 32, height: 32)
                    
                    // Habit info and progress
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(habit.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            // Tappable count display - plain white text
                            Button(action: {
                                inputValue = "\(habit.todayCount)"
                                showLoggingSheet = true
                            }) {
                                Text("\(habit.todayCount)/\(habit.targetCount) \(habit.unit)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        ProgressView(value: habit.todayProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
                    }
                }
                
                // Horizontal divider
                Divider()
                    .background(Color(.systemGray4))
                
                // Yearly contribution graph
                ContributionGraph(habit: habit)
                    .frame(height: 60)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
        }
        .scaleEffect(isDragging ? 0.98 : 1.0)
        .offset(dragOffset)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    // Only respond to strongly horizontal drags to avoid interfering with scrolling
                    let horizontalAmount = abs(value.translation.width)
                    let verticalAmount = abs(value.translation.height)
                    
                    // More restrictive: horizontal must be at least 2x vertical movement and >20 points
                    if horizontalAmount > max(verticalAmount * 2, 20) {
                        withAnimation(.spring(response: 0.3)) {
                            dragOffset = CGSize(width: value.translation.width, height: 0)
                            isDragging = true
                        }
                    }
                }
                .onEnded { value in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        dragOffset = .zero
                        isDragging = false
                    }
                    
                    // Only trigger on strongly horizontal swipes
                    let horizontalAmount = abs(value.translation.width)
                    let verticalAmount = abs(value.translation.height)
                    
                    if horizontalAmount > max(verticalAmount * 2, 50) {
                        inputValue = "\(habit.todayCount)"
                        showLoggingSheet = true
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                }
        )
        .onTapGesture {
            inputValue = "\(habit.todayCount)"
            showLoggingSheet = true
        }
        .sheet(isPresented: $showLoggingSheet) {
            HabitLoggingSheet(
                habit: habit,
                inputValue: $inputValue,
                onSave: { value in
                    if let count = Int(value) {
                        habitManager.setHabitCount(habit, count: count)
                        
                        if count >= habit.targetCount {
                            let notificationFeedback = UINotificationFeedbackGenerator()
                            notificationFeedback.notificationOccurred(.success)
                        }
                    }
                }
            )
        }
    }
}


// Helper extension for hex colors
extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    TodayView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
        .environmentObject(StoreManager())
}
