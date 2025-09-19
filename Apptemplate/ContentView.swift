//
//  ContentView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var storeManager: StoreManager
    @StateObject private var habitManager: HabitManager
    
    init() {
        // Initialize with a temporary ModelContext that will be replaced in onAppear
        let container = try! ModelContainer(for: Habit.self, HabitEntry.self)
        let context = ModelContext(container)
        self._habitManager = StateObject(wrappedValue: HabitManager(modelContext: context))
    }
    
    var body: some View {
        MainTabView()
            .environmentObject(habitManager)
            .onAppear {
                // Update the habit manager with the actual model context from the environment
                habitManager.modelContext = modelContext
                habitManager.loadHabits()
            }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreManager())
        .modelContainer(for: [Habit.self, HabitEntry.self])
}
