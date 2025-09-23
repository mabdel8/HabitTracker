//
//  HabitTips.swift
//  Apptemplate
//
//  Created by Mohamed Abdelmagid on 8/19/25.
//

import SwiftUI
import TipKit

// MARK: - Habit Logging Tip
struct HabitLoggingTip: Tip {
    var title: Text {
        Text("Log Your Habits")
    }
    
    var message: Text? {
        Text("Tap the habit card or swipe left/right to quickly log your progress")
    }
    
    var image: Image? {
        Image(systemName: "hand.tap.fill")
    }
    
    // Show this tip when user has their first habit
    var rules: [Rule] {
        #Rule(Self.$hasAddedFirstHabit) { $0 == true }
    }
    
    // Track if user has added their first habit
    @Parameter
    static var hasAddedFirstHabit: Bool = false
}

// MARK: - TipKit Configuration Extension
extension Tips {
    static func configure() {
        // Configure TipKit
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }
}