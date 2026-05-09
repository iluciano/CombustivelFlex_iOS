import SwiftUI

struct RootTabView: View {
    @State private var selectedTab = AppTab.home
    @State private var homePath = NavigationPath()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settingsStore = SettingsStore()

    var body: some View {
        TabView(selection: selectedTabBinding) {
            NavigationStack(path: $homePath) {
                StartView(
                    selectTab: { tab in
                        selectTab(tab)
                    },
                    navigate: { route in
                        homePath.append(route)
                    }
                )
                .navigationDestination(for: HomeRoute.self) { route in
                    destination(for: route)
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
        .environmentObject(historyStore)
        .environmentObject(settingsStore)
    }

    private var selectedTabBinding: Binding<AppTab> {
        Binding(
            get: { selectedTab },
            set: { tab in
                selectTab(tab)
            }
        )
    }

    private func selectTab(_ tab: AppTab) {
        let previousTab = selectedTab

        if tab == .home && previousTab != .home {
            homePath = NavigationPath()
        }

        selectedTab = tab
    }

    private func icon(for tab: AppTab) -> String {
        selectedTab == tab ? tab.selectedSystemImage : tab.systemImage
    }

    @ViewBuilder
    private func destination(for route: HomeRoute) -> some View {
        switch route {
        case .calculator:
            CalculatorView()
        case .tips:
            TipsView()
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    RootTabView()
}
