import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = AppTab.home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                StartView { tab in
                    selectedTab = tab
                }
            }
            .tabItem {
                Label(AppTab.home.title, systemImage: icon(for: .home))
            }
            .tag(AppTab.home)

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label(AppTab.history.title, systemImage: icon(for: .history))
            }
            .tag(AppTab.history)

            NavigationStack {
                StationsView()
            }
            .tabItem {
                Label(AppTab.stations.title, systemImage: icon(for: .stations))
            }
            .tag(AppTab.stations)

            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label(AppTab.more.title, systemImage: icon(for: .more))
            }
            .tag(AppTab.more)
        }
        .tint(AppTheme.Colors.blue)
    }

    private func icon(for tab: AppTab) -> String {
        selectedTab == tab ? tab.selectedSystemImage : tab.systemImage
    }
}

#Preview {
    RootTabView()
}
