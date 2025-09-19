//
//  TodayView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingHabitCreation = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
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
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date(), style: .date)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Your Progress")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if totalCount > 0 {
                    progressRing
                }
            }
            
            if totalCount > 0 {
                progressBar
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray4), lineWidth: 6)
                .frame(width: 60, height: 60)
            
            Circle()
                .trim(from: 0, to: totalCount > 0 ? Double(completedCount) / Double(totalCount) : 0)
                .stroke(Color.green, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: completedCount)
            
            Text("\(completedCount)")
                .font(.headline)
                .fontWeight(.bold)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.3), value: completedCount)
        }
    }
    
    private var progressBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(completedCount) of \(totalCount) completed")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int((Double(completedCount) / Double(totalCount)) * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: Double(completedCount), total: Double(totalCount))
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
        }
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
            }
        }
    }
}

struct HabitRowView: View {
    let habit: Habit
    @EnvironmentObject var habitManager: HabitManager
    @State private var showCompletionAnimation = false
    
    private var progressColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: habit.icon)
                .font(.title2)
                .foregroundStyle(progressColor)
                .frame(width: 32, height: 32)
            
            // Habit info and progress
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(habit.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("\(habit.todayCount)/\(habit.targetCount) \(habit.unit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                ProgressView(value: habit.todayProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressColor))
            }
            
            // Controls
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        habitManager.decrementHabit(habit)
                    }
                    
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(habit.todayCount > 0 ? progressColor : Color(.systemGray4))
                        .scaleEffect(habit.todayCount > 0 ? 1.0 : 0.8)
                        .animation(.spring(response: 0.3), value: habit.todayCount)
                }
                .disabled(habit.todayCount == 0)
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        habitManager.incrementHabit(habit)
                    }
                    
                    // Haptic feedback - stronger for completion
                    if habit.todayCount + 1 >= habit.targetCount {
                        let notificationFeedback = UINotificationFeedbackGenerator()
                        notificationFeedback.notificationOccurred(.success)
                    } else {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(progressColor)
                        .scaleEffect(1.0)
                        .animation(.spring(response: 0.3), value: habit.todayCount)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .overlay(
            // Completion animation overlay
            ZStack {
                if showCompletionAnimation {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(progressColor.opacity(0.3))
                        .scaleEffect(showCompletionAnimation ? 1.05 : 1.0)
                        .opacity(showCompletionAnimation ? 0 : 1)
                }
            }
        )
        .onChange(of: habit.isCompletedToday) { _, isCompleted in
            if isCompleted {
                withAnimation(.easeOut(duration: 0.6)) {
                    showCompletionAnimation = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showCompletionAnimation = false
                }
            }
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