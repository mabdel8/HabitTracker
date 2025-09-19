//
//  SettingsView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject var habitManager: HabitManager
    @EnvironmentObject var storeManager: StoreManager
    @State private var showingHabitCreation = false
    @State private var showingPaywall = false
    @State private var editingHabit: Habit?
    
    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                
                habitsSection
                
                aboutSection
            }
            .navigationTitle("Settings")
        }
        .sheet(isPresented: $showingHabitCreation) {
            HabitCreationView()
                .environmentObject(habitManager)
                .environmentObject(storeManager)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(isPresented: $showingPaywall)
                .environmentObject(storeManager)
        }
        .sheet(item: $editingHabit) { habit in
            HabitEditView(habit: habit)
                .environmentObject(habitManager)
        }
    }
    
    private var subscriptionSection: some View {
        Section {
            HStack {
                Image(systemName: storeManager.isSubscribed ? "crown.fill" : "star.fill")
                    .font(.title2)
                    .foregroundStyle(storeManager.isSubscribed ? .yellow : .gray)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(storeManager.isSubscribed ? "Premium Member" : "Free User")
                        .font(.headline)
                    
                    Text(storeManager.isSubscribed ? 
                         "Unlimited habits and features" : 
                         "Limited to 3 habits")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if !storeManager.isSubscribed {
                    Button("Upgrade") {
                        showingPaywall = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Subscription")
        }
    }
    
    private var habitsSection: some View {
        Section {
            if habitManager.habits.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("No habits yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Tap the + button to add your first habit")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(habitManager.habits, id: \.id) { habit in
                    HabitSettingsRow(habit: habit) {
                        editingHabit = habit
                    }
                }
                .onDelete(perform: deleteHabits)
                .onMove(perform: moveHabits)
            }
            
            Button(action: {
                if storeManager.isSubscribed || habitManager.habits.count < 3 {
                    showingHabitCreation = true
                } else {
                    showingPaywall = true
                }
            }) {
                Label("Add Habit", systemImage: "plus.circle.fill")
                    .foregroundStyle(.blue)
            }
            
        } header: {
            HStack {
                Text("My Habits")
                Spacer()
                if !habitManager.habits.isEmpty {
                    Text("\(habitManager.habits.count)\(storeManager.isSubscribed ? "" : "/3")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } footer: {
            if !storeManager.isSubscribed && habitManager.habits.count >= 3 {
                Text("Upgrade to Premium to add unlimited habits")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }
            
            if storeManager.isSubscribed {
                Button("Restore Purchases") {
                    Task {
                        await storeManager.restorePurchases()
                    }
                }
            }
        }
    }
    
    private func deleteHabits(at offsets: IndexSet) {
        for index in offsets {
            let habit = habitManager.habits[index]
            habitManager.deleteHabit(habit)
        }
    }
    
    private func moveHabits(from source: IndexSet, to destination: Int) {
        var updatedHabits = habitManager.habits
        updatedHabits.move(fromOffsets: source, toOffset: destination)
        
        // Update sort orders
        for (index, habit) in updatedHabits.enumerated() {
            habit.sortOrder = index
        }
        
        habitManager.loadHabits()
    }
}

struct HabitSettingsRow: View {
    let habit: Habit
    let onEdit: () -> Void
    
    private var habitColor: Color {
        Color(hex: habit.color) ?? .blue
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: habit.icon)
                .font(.title3)
                .foregroundStyle(habitColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(habit.name)
                    .font(.headline)
                
                Text("\(habit.targetCount) \(habit.unit) daily")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button("Edit") {
                onEdit()
            }
            .font(.caption)
            .foregroundStyle(.blue)
        }
        .padding(.vertical, 2)
    }
}

struct HabitEditView: View {
    let habit: Habit
    @EnvironmentObject var habitManager: HabitManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var icon: String
    @State private var color: String
    @State private var targetCount: Int
    @State private var unit: String
    
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
    
    init(habit: Habit) {
        self.habit = habit
        self._name = State(initialValue: habit.name)
        self._icon = State(initialValue: habit.icon)
        self._color = State(initialValue: habit.color)
        self._targetCount = State(initialValue: habit.targetCount)
        self._unit = State(initialValue: habit.unit)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Habit Details") {
                    TextField("Habit name", text: $name)
                    
                    HStack {
                        Text("Target")
                        Spacer()
                        TextField("1", value: $targetCount, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        
                        Picker("Unit", selection: $unit) {
                            ForEach(availableUnits, id: \.self) { unit in
                                Text(unit).tag(unit)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("Appearance") {
                    HStack {
                        Text("Icon")
                        Spacer()
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(availableIcons, id: \.self) { iconName in
                                    Button(action: {
                                        icon = iconName
                                    }) {
                                        Image(systemName: iconName)
                                            .font(.title2)
                                            .foregroundStyle(icon == iconName ? .white : .primary)
                                            .frame(width: 44, height: 44)
                                            .background(icon == iconName ? Color.blue : Color(.systemGray6))
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
                                ForEach(availableColors, id: \.self) { colorHex in
                                    Button(action: {
                                        color = colorHex
                                    }) {
                                        Circle()
                                            .fill(Color(hex: colorHex) ?? .blue)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(color == colorHex ? Color.primary : Color.clear, lineWidth: 3)
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 1)
                        }
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func saveChanges() {
        habit.name = name
        habit.icon = icon
        habit.color = color
        habit.targetCount = targetCount
        habit.unit = unit
        
        habitManager.updateHabit(habit)
        dismiss()
    }
}

#Preview {
    SettingsView()
        .environmentObject(HabitManager(modelContext: ModelContext(try! ModelContainer(for: Habit.self))))
        .environmentObject(StoreManager())
}