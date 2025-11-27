import SwiftUI

// MARK: - 3. TAB NAVIGATION
struct MainTabView: View {
    var body: some View {
        TabView {
            BarbellPRsView()
                .tabItem {
                    Label("Barbell PRs", systemImage: "trophy.fill")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }

            LogWorkoutView()
                .tabItem {
                    Label("Log Lift", systemImage: "plus.circle.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}
