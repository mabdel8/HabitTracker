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
        "bed.double.fill", "figure.walk", "dumbbell.fill", "cup.and.saucer.fill"
    ]
    
    private let availableColors = [
        "#007AFF", "#FF3B30", "#FF9500", "#AF52DE", "#34C759",
        "#5856D6", "#FF2D92", "#32D74B", "#00C7BE", "#FFD60A"
    ]
    
    private let availableUnits = [
        "times", "minutes", "hours", "glasses", "pages", "steps", "sessions"
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
            VStack(spacing: 24) {
                headerSection
                
                templatesSection
                
                customOptionSection
            }
            .padding()
        }
        .navigationTitle("Add Habit")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundStyle(.blue)
            
            Text("Choose a habit to track")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start with a popular habit or create your own")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var templatesSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
            ForEach(HabitManager.predefinedTemplates, id: \.name) { template in
                TemplateCard(template: template) {
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
                    
                    Text("Create Custom Habit")
                        .font(.headline)
                }
                .foregroundStyle(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
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
                    .padding(.leading, 60)
                }
            }
            
            Section("Appearance") {
                HStack {
                    Text("Icon")
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: {
                                    customIcon = icon
                                }) {
                                    Image(systemName: icon)
                                        .font(.title2)
                                        .foregroundStyle(customIcon == icon ? .white : .primary)
                                        .frame(width: 44, height: 44)
                                        .background(customIcon == icon ? (Color(hex: customColor) ?? .blue) : Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
                
                HStack {
                    Text("Color")
                    Spacer()
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(availableColors, id: \.self) { color in
                                Button(action: {
                                    customColor = color
                                }) {
                                    Circle()
                                        .fill(Color(hex: color) ?? .blue)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Circle()
                                                .stroke(customColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
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

struct TemplateCard: View {
    let template: HabitTemplate
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: template.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color(hex: template.color) ?? .blue)
                
                Text(template.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(template.targetCount) \(template.unit)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HabitCreationView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
        .environmentObject(StoreManager())
}