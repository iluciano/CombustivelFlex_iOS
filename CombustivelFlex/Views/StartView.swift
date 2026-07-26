import SwiftUI

enum HomeRoute: Hashable {
    case calculator(CalculatorInitialTab = .calculator)
    case tips
    case settings
}

struct StartView: View {
    let selectTab: (AppTab) -> Void
    let navigate: (HomeRoute) -> Void

    var body: some View {
        ScrollView {
            RoadHeaderView()
                .frame(height: 255)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            VStack(spacing: AppTheme.Spacing.large) {
                brandHeader

                VStack(spacing: AppTheme.Spacing.medium) {
                    calculatorAction
                    historyAction
                    tabAction(.stations, item: .stations)
                    tabAction(.maintenance, item: .maintenance)
                    tipsAction
                    settingsAction
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, 34)
            .padding(.bottom, AppTheme.Spacing.large)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 5)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .offset(y: -70)
            .padding(.bottom, -46)
        }
        .background(AppTheme.Colors.background)
        .ignoresSafeArea(edges: .top)
        .buttonStyle(.plain)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var calculatorAction: some View {
        Button {
            navigate(.calculator())
        } label: {
            StartActionRow(item: .calculator)
        }
    }

    private var historyAction: some View {
        Button {
            navigate(.calculator(.history))
        } label: {
            StartActionRow(item: .history)
        }
    }

    private func tabAction(_ tab: AppTab, item: StartActionItem) -> some View {
        Button {
            selectTab(tab)
        } label: {
            StartActionRow(item: item)
        }
    }

    private var tipsAction: some View {
        Button {
            navigate(.tips)
        } label: {
            StartActionRow(item: .tips)
        }
    }

    private var settingsAction: some View {
        Button {
            navigate(.settings)
        } label: {
            StartActionRow(item: .settings)
        }
    }

    private var brandHeader: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack(spacing: AppTheme.Spacing.small) {
                AppLogoIcon()

                HStack(spacing: 4) {
                    Text("COMBUSTÍVEL")
                        .foregroundStyle(AppTheme.Colors.textPrimary)

                    Text("FLEX")
                        .foregroundStyle(AppTheme.Colors.blue)
                }
                .font(.title2.bold())
            }

            Text("Qual o melhor combustível para o seu carro?")
                .font(.body)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }
}

private struct StartActionItem {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color
    let badge: String?
    let isHighlighted: Bool

    init(
        title: String,
        subtitle: String,
        systemImage: String,
        tint: Color,
        badge: String? = nil,
        isHighlighted: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.systemImage = systemImage
        self.tint = tint
        self.badge = badge
        self.isHighlighted = isHighlighted
    }
}

private extension StartActionItem {
    static let calculator = StartActionItem(
        title: "Calcular combustível",
        subtitle: "Veja qual opção é mais econômica para você",
        systemImage: "fuelpump.fill",
        tint: AppTheme.Colors.orange
    )

    static let history = StartActionItem(
        title: "Histórico",
        subtitle: "Acompanhe seus cálculos anteriores",
        systemImage: "clock",
        tint: AppTheme.Colors.blue
    )

    static let stations = StartActionItem(
        title: "Postos próximos",
        subtitle: "Encontre postos de gasolina perto de você",
        systemImage: "mappin.circle.fill",
        tint: AppTheme.Colors.green
    )

    static let maintenance = StartActionItem(
        title: "Manutenção",
        subtitle: "Acompanhe as manutenções do carro",
        systemImage: "wrench.and.screwdriver.fill",
        tint: AppTheme.Colors.blue
    )

    static let tips = StartActionItem(
        title: "Dicas de economia",
        subtitle: "Aprenda a economizar combustível no dia a dia",
        systemImage: "lightbulb.fill",
        tint: AppTheme.Colors.orange
    )

    static let settings = StartActionItem(
        title: "Configurações",
        subtitle: "Personalize suas preferências e o aplicativo",
        systemImage: "gearshape.fill",
        tint: AppTheme.Colors.textMuted
    )
}

struct BrandIcon: View {
    var size: CGFloat = 36

    var body: some View {
        AppLogoIcon(size: size)
    }
}

struct AppLogoIcon: View {
    var size: CGFloat = 36

    var body: some View {
        Image("app_logo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

private struct StartActionRow: View {
    let item: StartActionItem

    var body: some View {
        HStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: item.systemImage)
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(item.tint)
                .frame(width: 64, height: 64)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: AppTheme.Spacing.small) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .lineLimit(2)

                    if let badge = item.badge {
                        Text(badge)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.Colors.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    }
                }

                Text(item.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: AppTheme.Spacing.small)

            Image(systemName: "chevron.right")
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .background(item.isHighlighted ? AppTheme.Colors.orange.opacity(0.06) : AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(item.isHighlighted ? AppTheme.Colors.orange.opacity(0.18) : AppTheme.Colors.divider, lineWidth: 1)
        }
    }
}

struct RoadHeaderView: View {
    var body: some View {
        GeometryReader { proxy in
            Image("road_header")
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
        }
    }
}

#Preview {
    NavigationStack {
        StartView(
            selectTab: { _ in },
            navigate: { _ in }
        )
    }
}
