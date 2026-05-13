import SwiftUI
import UIKit

struct RootTabView: View {
    @State private var selectedTab = AppTab.home
    @State private var homePath = NavigationPath()
    @StateObject private var historyStore = HistoryStore()
    @StateObject private var settingsStore = SettingsStore()

    init() {
        configureTabBarAppearance()
    }

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

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = UIBlurEffect(style: .systemChromeMaterial)
        appearance.shadowColor = .clear

        let selectedColor = UIColor.tabBarSelected
        let unselectedColor = UIColor.tabBarUnselected
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
        ]
        let unselectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: unselectedColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]

        [
            appearance.stackedLayoutAppearance,
            appearance.inlineLayoutAppearance,
            appearance.compactInlineLayoutAppearance
        ].forEach { itemAppearance in
            itemAppearance.selected.iconColor = selectedColor
            itemAppearance.selected.titleTextAttributes = selectedAttributes
            itemAppearance.normal.iconColor = unselectedColor
            itemAppearance.normal.titleTextAttributes = unselectedAttributes
        }

        let tabBarAppearance = UITabBar.appearance()
        tabBarAppearance.standardAppearance = appearance
        tabBarAppearance.scrollEdgeAppearance = appearance
        tabBarAppearance.tintColor = selectedColor
        tabBarAppearance.unselectedItemTintColor = unselectedColor
        tabBarAppearance.isTranslucent = true
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

private extension UIColor {
    static let tabBarSelected = UIColor(hex: 0x1473F8)

    static let tabBarUnselected = UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark
            ? UIColor(white: 1, alpha: 0.86)
            : UIColor(hex: 0x101828)
    }
}
