# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

**Build and Run**:
- `xcodebuild -project Apptemplate.xcodeproj -scheme Apptemplate build` - Build the project
- Open `Apptemplate.xcodeproj` in Xcode and press Cmd+R to run

**Testing StoreKit**:
- Use Xcode's StoreKit Testing environment with the provided `apptemplatestorekit.storekit` configuration file
- Products are configured: `template_weekly` (weekly subscription with 3-day free trial) and `template_lifetime` (one-time purchase)

## Architecture Overview

This is a SwiftUI-based iOS app with StoreKit integration for subscription management. The app follows a subscription-based model with onboarding flow.

### Core Architecture Components

**App Flow**:
- `ApptemplateApp.swift` - Main app entry point with subscription state management
- `OnboardingView.swift` - Initial welcome screen, shown to new users
- `ContentView.swift` - Main app content, shows subscription status
- `PaywallView.swift` - Subscription purchase interface

**Subscription System**:
- `StoreManager.swift` - Core StoreKit integration with subscription state management
- Two product types: `template_weekly` (recurring) and `template_lifetime` (non-renewable)
- Automatic subscription status checking and transaction listening
- Purchase state management with loading states and error handling

**Data Layer**:
- `Item.swift` - SwiftData model (currently minimal, appears to be template placeholder)
- Uses `@AppStorage` for persisting onboarding completion state
- StoreKit handles subscription persistence

### Key Technical Patterns

**State Management**:
- `@StateObject` for StoreManager lifecycle management
- `@EnvironmentObject` for passing StoreManager down the view hierarchy
- `@AppStorage` for simple persistent user preferences
- `@Published` properties in StoreManager for reactive UI updates

**StoreKit Integration**:
- Transaction verification with `.verified`/`.unverified` handling
- Background transaction listener for subscription updates
- Product loading from StoreKit configuration
- Purchase restoration functionality

**View Architecture**:
- Declarative SwiftUI with clear separation of concerns
- Sheet-based navigation for paywall presentation
- Conditional view rendering based on subscription and onboarding state

### Bundle Configuration

- Bundle ID: `com.mohamedabdelmagid.habittracker`
- StoreKit products defined in `apptemplatestorekit.storekit`
- App icon and assets in `Assets.xcassets`

## Habit Tracking Features

**Core Functionality**:
- **Today View**: Primary interface for daily habit logging with progress tracking
- **Weekly View**: 7-day progress grid showing completion status for each habit
- **Calendar View**: Monthly heatmap and contribution graph (GitHub-style) for long-term tracking
- **Settings View**: Habit management, creation, editing, and subscription controls

**Data Models**:
- `Habit`: Core habit entity with name, icon, color, target count, unit
- `HabitEntry`: Daily tracking entries linked to habits with date and count
- `HabitManager`: Data operations and business logic for habit management

**Key Features**:
- 8 predefined habit templates (Water, Exercise, Read, Meditate, etc.)
- Custom habit creation with icons, colors, and targets
- Real-time progress tracking with visual feedback
- Haptic feedback and smooth animations
- Freemium model: 3 habits free, unlimited with subscription

**UI Components**:
- `TodayView`: Daily logging interface with increment/decrement controls
- `WeeklyView`: Grid-based weekly progress visualization
- `CalendarView`: Monthly heatmap and yearly contribution graph
- `HabitCreationView`: Template selection and custom habit creation
- `SettingsView`: Habit management and subscription integration