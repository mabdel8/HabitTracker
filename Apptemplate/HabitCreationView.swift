//
//  HabitCreationView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct HabitCreationView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingTemplates = true
    @State private var selectedTemplate: HabitTemplate?
    @State private var customName = ""
    @State private var customIcon = "star.fill"
    @State private var customColor = "#007AFF"
    @State private var customTarget = 1
    @State private var customUnit = "times"
    
    private let availableIcons = [
        "star.fill", "heart.fill", "flame.fill", "bolt.fill", "leaf.fill",
        "drop.fill", "book.fill", "pencil", "figure.run", "brain.head.profile",
        "bed.double.fill", "figure.walk", "dumbbell.fill", "cup.and.saucer.fill",
        "sun.max.fill", "moon.fill", "alarm.fill", "timer", "stopwatch.fill",
        "calendar", "clock.fill", "car.fill", "bicycle", "airplane",
        "house.fill", "building.2.fill", "figure.indoor.cycle", "carrot.fill", "leaf",
        "globe", "map.fill", "location.fill", "compass.drawing", "binoculars.fill",
        "camera.fill", "phone.fill", "headphones", "gamecontroller.fill", "tv.fill"
    ]
    
    private let availableColors = [
        "#007AFF", "#FF3B30", "#FF9500", "#AF52DE", "#34C759",
        "#5856D6", "#FF2D92", "#32D74B", "#00C7BE", "#FFD60A",
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#96CEB4", "#FECA57",
        "#FF9FF3", "#54A0FF", "#5F27CD", "#00D2D3", "#FF9F43",
        "#EE5A24", "#009432", "#0652DD", "#9980FA", "#833471",
        "#EA2027", "#006BA6", "#1B1464", "#5758BB", "#6F1E51"
    ]
    
    private let availableUnits = [
        "times", "minutes", "hours", "glasses", "pages", "steps", "sessions",
        "miles", "km", "calories", "cal", "grams", "g", "mg", "ml", "liters", "l",
        "reps", "sets", "laps", "cups", "oz", "servings", "doses", "chapters"
    ]
    
    var body: some View {
        NavigationStack {
            if showingTemplates {
                templatesView
            } else {
                customHabitView
            }
        }
    }
    
    private var templatesView: some View {
        ScrollView {
            VStack(spacing: 20) {
                popularHabitsSection
                
                customOptionSection
            }
            .padding()
        }
        .navigationTitle("Popular Habits")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    
    private var popularHabitsSection: some View {
        LazyVStack(spacing: 12) {
            ForEach(HabitManager.predefinedTemplates, id: \.name) { template in
                HabitListCard(template: template) {
                    selectedTemplate = template
                    addHabitFromTemplate(template)
                }
            }
        }
    }
    
    private var customOptionSection: some View {
        VStack(spacing: 16) {
            Divider()
            
            Button(action: {
                showingTemplates = false
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.black)
                    
                    Text("Create Custom Habit")
                        .font(.headline)
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
            }
        }
    }
    
    private var customHabitView: some View {
        Form {
            Section("Habit Details") {
                TextField("Habit name", text: $customName)
                
                HStack {
                    Text("Target")
                    Spacer()
                    TextField("1", value: $customTarget, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    
                    Picker("Unit", selection: $customUnit) {
                        ForEach(availableUnits, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            
            Section("Appearance") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Icon")
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 8) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Button(action: {
                                customIcon = icon
                            }) {
                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(customIcon == icon ? .white : .primary)
                                    .frame(width: 40, height: 40)
                                    .background(customIcon == icon ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 8) {
                        ForEach(availableColors, id: \.self) { color in
                            Button(action: {
                                customColor = color
                            }) {
                                Circle()
                                    .fill(Color(hex: color) ?? .blue)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(customColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .navigationTitle("Custom Habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back") {
                    showingTemplates = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") {
                    addCustomHabit()
                }
                .disabled(customName.isEmpty)
            }
        }
    }
    
    private func addHabitFromTemplate(_ template: HabitTemplate) {
        let habit = template.createHabit()
        habitManager.addHabit(habit)
        dismiss()
    }
    
    private func addCustomHabit() {
        let habit = Habit(
            name: customName,
            icon: customIcon,
            color: customColor,
            targetCount: customTarget,
            unit: customUnit
        )
        habitManager.addHabit(habit)
        dismiss()
    }
}

struct HabitListCard: View {
    let template: HabitTemplate
    let action: () -> Void
    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: template.icon)
                .font(.title2)
                .foregroundStyle(Color(hex: template.color) ?? .blue)
                .frame(width: 32, height: 32)
            
            // Habit info
            VStack(alignment: .leading, spacing: 4) {
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text("Goal: \(template.targetCount) \(template.unit)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Add indicator
            Image(systemName: "plus.circle.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        )
        .onTapGesture {
            if !isDragging {
                action()
            }
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { _ in
                    isDragging = true
                }
                .onEnded { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isDragging = false
                    }
                }
        )
    }
}

#Preview {
    HabitCreationView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
        .environmentObject(StoreManager())
}
