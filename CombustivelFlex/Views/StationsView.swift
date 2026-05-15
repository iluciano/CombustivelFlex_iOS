import SwiftUI
import UIKit

struct StationsView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = StationsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                header

                content
            }
            .padding(AppTheme.Spacing.large)
            .background(AppTheme.Colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 5)
            .padding(.horizontal, AppTheme.Spacing.medium)
            .padding(.top, AppTheme.Spacing.large)
            .padding(.bottom, viewModel.stations.isEmpty ? 120 : 118)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !viewModel.stations.isEmpty {
                VStack(spacing: 0) {
                    Button {
                        openNearbyStationsMap()
                    } label: {
                        Text("VER NO MAPA")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(AppTheme.Colors.blue)
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppTheme.Spacing.large)
                    .padding(.top, AppTheme.Spacing.small)
                    .padding(.bottom, AppTheme.Spacing.small)

                    Color.clear
                        .frame(height: 8)
                }
                .background(AppTheme.Colors.background.opacity(0.96))
            }
        }
        .task {
            viewModel.start()
        }
    }

    private var header: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Postos próximos")
                    .font(.title2.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                Button {
                    viewModel.refresh()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin")
                            .font(.caption.weight(.semibold))

                        Text("Localização atual")
                            .font(.caption.weight(.medium))
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.Colors.blue)
                .accessibilityLabel("Atualizar postos pela localização atual")
            }

            Spacer()

            Button {
                viewModel.refresh()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Atualizar lista de postos")
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.locationPermissionDenied {
            StationsStateView(
                systemImage: "location.slash.fill",
                title: "Permita o acesso à localização",
                message: "A localização é necessária para ordenar os postos mais próximos de você.",
                buttonTitle: "Abrir Ajustes",
                action: openAppSettings
            )
        } else if viewModel.isLoading {
            VStack(spacing: AppTheme.Spacing.medium) {
                ProgressView()
                    .tint(AppTheme.Colors.blue)

                Text("Buscando postos próximos...")
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 72)
        } else if let errorMessage = viewModel.errorMessage {
            StationsStateView(
                systemImage: "wifi.exclamationmark",
                title: "Não foi possível carregar",
                message: errorMessage,
                buttonTitle: "Tentar novamente",
                action: viewModel.refresh
            )
        } else if viewModel.stations.isEmpty {
            if viewModel.hasStationsOutsideSearchRadius {
                StationsStateView(
                    systemImage: "location.magnifyingglass",
                    title: "Nenhum posto em até 5 km",
                    message: "Encontramos postos cadastrados, mas nenhum está dentro de um raio de 5 km da sua localização atual.",
                    buttonTitle: "Atualizar localização",
                    action: viewModel.refresh
                )
            } else {
                StationsStateView(
                    systemImage: "fuelpump.fill",
                    title: "Nenhum posto encontrado",
                    message: "Ainda não há postos cadastrados próximos à sua localização atual.",
                    buttonTitle: "Atualizar",
                    action: viewModel.refresh
                )
            }
        } else {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.stations) { station in
                    NavigationLink {
                        StationDetailView(station: station, mapsURL: viewModel.routeMapsURL(for: station))
                    } label: {
                        StationRow(station: station)
                    }
                    .buttonStyle(.plain)

                    if station.id != viewModel.stations.last?.id {
                        Divider()
                            .padding(.leading, 78)
                    }
                }
            }
            .background(AppTheme.Colors.surface)
        }
    }

    private func openMap(for station: FuelStation) {
        guard let url = viewModel.mapsURL(for: station) else {
            return
        }

        openURL(url)
    }

    private func openNearbyStationsMap() {
        guard let url = viewModel.nearbyGasStationsMapsURL() else {
            return
        }

        openURL(url)
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(url)
    }
}

private struct StationRow: View {
    let station: FuelStation

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            StationBrandBadge(brand: station.brand)

            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .lineLimit(3)

                Text(distanceText)
                    .font(.caption)
                    .foregroundStyle(AppTheme.Colors.textMuted)
            }

            Spacer(minLength: AppTheme.Spacing.small)

            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 4) {
                    FuelPriceBlock(
                        value: station.regularGasolinePrice,
                        label: "Gasolina comum",
                        tint: AppTheme.Colors.blue
                    )

                    FuelPriceBlock(
                        value: station.ethanolPrice,
                        label: "Etanol",
                        tint: AppTheme.Colors.green
                    )
                }

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.textMuted)
            }
        }
        .padding(.vertical, 13)
        .padding(.horizontal, AppTheme.Spacing.medium)
        .contentShape(Rectangle())
    }

    private var distanceText: String {
        guard let distanceMeters = station.distanceMeters else {
            return "Distância indisponível"
        }

        if distanceMeters < 1_000 {
            return "\(Int(distanceMeters.rounded())) m"
        }

        let kilometers = distanceMeters / 1_000
        return String(format: "%.1f km", locale: Locale(identifier: "pt_BR"), kilometers)
    }
}

private struct FuelPriceBlock: View {
    let value: Double?
    let label: String
    let tint: Color

    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(priceText)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(AppTheme.Colors.textMuted)
                .lineLimit(1)
        }
    }

    private var priceText: String {
        guard let value else {
            return "R$ --"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "R$ 0,00"
    }
}

private struct StationBrandBadge: View {
    let brand: FuelStationBrand

    var body: some View {
        ZStack {
            if let logoAssetName = brand.logoAssetName {
                Image(logoAssetName)
                    .resizable()
                    .scaledToFit()
            } else {
                Circle()
                    .fill(Color(hex: 0x98A2B3))

                Text("?")
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 44, height: 44)
        .accessibilityLabel(brand.displayName)
    }

    private var tint: Color {
        switch brand {
        case .ipiranga:
            return Color(hex: 0xFFB000)
        case .shell:
            return Color(hex: 0xD71920)
        case .br:
            return AppTheme.Colors.green
        case .ale:
            return AppTheme.Colors.orange
        case .totalenergies:
            return Color(hex: 0x18427A)
        case .unknown:
            return AppTheme.Colors.blue
        }
    }
}

private struct StationsStateView: View {
    let systemImage: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        AppCard {
            VStack(spacing: AppTheme.Spacing.medium) {
                Image(systemName: systemImage)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.blue)

                Text(title)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(.body)
                    .foregroundStyle(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                Button(action: action) {
                    Text(buttonTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(AppTheme.Colors.blue)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.top, AppTheme.Spacing.small)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppTheme.Spacing.large)
        }
    }
}

#Preview {
    NavigationStack {
        StationsView()
    }
}
