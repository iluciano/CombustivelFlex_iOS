import SwiftUI

struct StartView: View {
    let selectTab: (AppTab) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            AppTheme.Colors.background
                .ignoresSafeArea()

            RoadHeaderView()
                .frame(height: 255)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 185)

                    VStack(spacing: AppTheme.Spacing.large) {
                        brandHeader

                        VStack(spacing: AppTheme.Spacing.medium) {
                            calculatorAction
                            tabAction(.history, item: .history)
                            tabAction(.stations, item: .stations)
                            tipsAction
                            settingsAction
                        }
                    }
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, 34)
                    .padding(.bottom, AppTheme.Spacing.large)
                    .background(AppTheme.Colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 5)
                    .padding(.horizontal, AppTheme.Spacing.medium)
                    .padding(.bottom, AppTheme.Spacing.large)
                }
            }
            .buttonStyle(.plain)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var calculatorAction: some View {
        NavigationLink {
            CalculatorView()
        } label: {
            StartActionRow(item: .calculator)
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
        NavigationLink {
            PlaceholderView(
                title: "Dicas de economia",
                message: "As dicas serão migradas do app Android nas próximas etapas.",
                systemImage: "lightbulb"
            )
            .navigationTitle("Dicas")
        } label: {
            StartActionRow(item: .tips)
        }
    }

    private var settingsAction: some View {
        NavigationLink {
            PlaceholderView(
                title: "Configurações",
                message: "Preferências de consumo, unidade e notificações entram aqui.",
                systemImage: "gearshape.fill"
            )
            .navigationTitle("Configurações")
        } label: {
            StartActionRow(item: .settings)
        }
    }

    private var brandHeader: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            HStack(spacing: AppTheme.Spacing.small) {
                BrandIcon()

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
        tint: AppTheme.Colors.green,
        badge: "Novo",
        isHighlighted: true
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

private struct BrandIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous)
                .fill(AppTheme.Colors.blue)

            Image(systemName: "fuelpump.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
        .frame(width: 36, height: 36)
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

private struct RoadHeaderView: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(hex: 0x0A75B8), Color(hex: 0x7FC7EE)],
                    startPoint: .top,
                    endPoint: .center
                )

                MountainRange(width: width, height: height, yOffset: 72)
                    .fill(Color(hex: 0x7B6A57))

                MountainRange(width: width, height: height, yOffset: 91)
                    .fill(Color(hex: 0xD7C1A3))

                Rectangle()
                    .fill(Color(hex: 0xB58349))
                    .frame(height: height * 0.34)
                    .frame(maxHeight: .infinity, alignment: .bottom)

                Path { path in
                    path.move(to: CGPoint(x: width * 0.43, y: height))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.48))
                    path.addLine(to: CGPoint(x: width * 0.57, y: height))
                    path.closeSubpath()
                }
                .fill(Color(hex: 0x1B1E24))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.496, y: height))
                    path.addLine(to: CGPoint(x: width * 0.500, y: height * 0.50))
                    path.addLine(to: CGPoint(x: width * 0.504, y: height))
                    path.closeSubpath()
                }
                .fill(Color(hex: 0xF9C11C))
            }
        }
    }
}

private struct MountainRange: Shape {
    let width: CGFloat
    let height: CGFloat
    let yOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: height * 0.58))
        path.addLine(to: CGPoint(x: width * 0.13, y: yOffset + 22))
        path.addLine(to: CGPoint(x: width * 0.25, y: yOffset + 38))
        path.addLine(to: CGPoint(x: width * 0.39, y: yOffset - 18))
        path.addLine(to: CGPoint(x: width * 0.52, y: yOffset + 24))
        path.addLine(to: CGPoint(x: width * 0.67, y: yOffset - 7))
        path.addLine(to: CGPoint(x: width * 0.82, y: yOffset + 33))
        path.addLine(to: CGPoint(x: width, y: yOffset + 2))
        path.addLine(to: CGPoint(x: width, y: height * 0.70))
        path.addLine(to: CGPoint(x: 0, y: height * 0.70))
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        StartView { _ in }
    }
}
