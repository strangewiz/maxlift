import SwiftUI

// MARK: - 3. TAB NAVIGATION
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            BarbellPRsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Barbell PRs", systemImage: "trophy.fill")
                }
                .tag(0)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(1)

            LogWorkoutView()
                .tabItem {
                    Label("Log Lift", systemImage: "plus.circle.fill")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}
