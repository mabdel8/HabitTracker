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
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var selectedDays: Set<Weekday> = []
    @State private var showingReminderConfig = false
    
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
        .sheet(isPresented: $showingReminderConfig) {
            if let template = selectedTemplate {
                ReminderConfigView(
                    habitName: template.name,
                    defaultTarget: template.targetCount,
                    unit: template.unit,
                    reminderEnabled: $reminderEnabled,
                    reminderTime: $reminderTime,
                    selectedDays: $selectedDays,
                    onSave: { customTarget in
                        addHabitFromTemplate(template, customTarget: customTarget)
                        showingReminderConfig = false
                    },
                    onCancel: {
                        showingReminderConfig = false
                    }
                )
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
                    showingReminderConfig = true
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
            
            Section("Reminders") {
                Toggle("Enable Reminders", isOn: $reminderEnabled)
                
                if reminderEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Days")
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                Button(action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }) {
                                    Text(day.shortName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(selectedDays.contains(day) ? .white : .primary)
                                        .frame(width: 32, height: 32)
                                        .background(selectedDays.contains(day) ? Color.blue : Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.compact)
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
    
    private func addHabitFromTemplate(_ template: HabitTemplate, customTarget: Int? = nil) {
        let habit = template.createHabit(
            customTarget: customTarget,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderDays: reminderEnabled ? Array(selectedDays) : []
        )
        habitManager.addHabit(habit)
        
        // Schedule notification if enabled
        if reminderEnabled {
            Task {
                let notificationManager = NotificationManager.shared
                if await notificationManager.requestPermission() {
                    notificationManager.scheduleHabitReminder(for: habit)
                }
            }
        }
        
        dismiss()
    }
    
    private func addCustomHabit() {
        let habit = Habit(
            name: customName,
            icon: customIcon,
            color: customColor,
            targetCount: customTarget,
            unit: customUnit,
            reminderEnabled: reminderEnabled,
            reminderTime: reminderEnabled ? reminderTime : nil,
            reminderDays: reminderEnabled ? Array(selectedDays) : []
        )
        habitManager.addHabit(habit)
        
        // Schedule notification if enabled
        if reminderEnabled {
            Task {
                let notificationManager = NotificationManager.shared
                if await notificationManager.requestPermission() {
                    notificationManager.scheduleHabitReminder(for: habit)
                }
            }
        }
        
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

struct ReminderConfigView: View {
    let habitName: String
    let defaultTarget: Int
    let unit: String
    @Binding var reminderEnabled: Bool
    @Binding var reminderTime: Date
    @Binding var selectedDays: Set<Weekday>
    let onSave: (Int) -> Void
    let onCancel: () -> Void
    
    @State private var customTarget: Int
    
    init(habitName: String, defaultTarget: Int, unit: String, reminderEnabled: Binding<Bool>, reminderTime: Binding<Date>, selectedDays: Binding<Set<Weekday>>, onSave: @escaping (Int) -> Void, onCancel: @escaping () -> Void) {
        self.habitName = habitName
        self.defaultTarget = defaultTarget
        self.unit = unit
        self._reminderEnabled = reminderEnabled
        self._reminderTime = reminderTime
        self._selectedDays = selectedDays
        self.onSave = onSave
        self.onCancel = onCancel
        self._customTarget = State(initialValue: defaultTarget)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goal") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "target")
                                .font(.title2)
                                .foregroundStyle(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Daily Target")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Customize your goal amount")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        HStack {
                            Text("Target")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Button(action: {
                                    if customTarget > 1 {
                                        customTarget -= 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(customTarget > 1 ? .blue : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .disabled(customTarget <= 1)
                                
                                TextField("Target", value: $customTarget, format: .number)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 60)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    customTarget += 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Text(unit)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .frame(minWidth: 40, alignment: .leading)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "bell.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Set Reminder")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                
                                Text("Get notified to \(habitName.lowercased())")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $reminderEnabled)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                if reminderEnabled {
                    Section("Days") {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                            ForEach(Weekday.allCases, id: \.self) { day in
                                Button(action: {
                                    if selectedDays.contains(day) {
                                        selectedDays.remove(day)
                                    } else {
                                        selectedDays.insert(day)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(day.shortName)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text(day.fullName.prefix(3).uppercased())
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .foregroundStyle(selectedDays.contains(day) ? .white : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(selectedDays.contains(day) ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section("Time") {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                    }
                }
            }
            .navigationTitle("Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Habit") {
                        onSave(customTarget)
                    }
                    .fontWeight(.medium)
                    .disabled(reminderEnabled && selectedDays.isEmpty)
                }
            }
        }
    }
}

#Preview {
    HabitCreationView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
        .environmentObject(StoreManager())
}
