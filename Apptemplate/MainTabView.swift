//
//  MainTabView.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var habitManager: HabitManager
    @State private var showPaywall = false
    
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Today")
                }
            
            WeeklyView()
                .tabItem {
                    Image(systemName: "calendar.day.timeline.left")
                    Text("Weekly")
                }
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .accentColor(.white)
        .sheet(isPresented: $showPaywall) {
            PaywallView(isPresented: $showPaywall)
                .environmentObject(storeManager)
        }
        .task {
            await storeManager.updateSubscriptionStatus()
            
            // Show paywall for free users with more than 3 habits
            if !storeManager.isSubscribed && habitManager.habits.count >= 3 {
                showPaywall = true
            }
        }
        .onChange(of: habitManager.habits.count) { _, newCount in
            if !storeManager.isSubscribed && newCount > 3 {
                showPaywall = true
            }
        }
    }
}