import SwiftUI
import UIKit

struct StationsView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel = StationsViewModel()
    @State private var selectedMode: StationsListMode = .nearby
    @State private var favoriteStations: [FuelStation] = []
    @State private var selectedStation: FuelStation?
    @State private var shouldShowCollectionInfo = false

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
            .padding(.bottom, 118)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(
            isPresented: Binding(
                get: { selectedStation != nil },
                set: { isPresented in
                    if !isPresented {
                        selectedStation = nil
                        reloadFavorites()
                    }
                }
            )
        ) {
            if let selectedStation {
                StationDetailView(station: selectedStation, mapsURL: viewModel.routeMapsURL(for: selectedStation))
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
        .task {
            viewModel.start()
        }
        .onAppear {
            reloadFavorites()
        }
        .onChange(of: selectedMode) { _, mode in
            if mode == .favorites {
                reloadFavorites()
            }
        }
        .alert("Dados da ANP", isPresented: $shouldShowCollectionInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Os preços exibidos são coletados pela ANP (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis) com base em pesquisas realizadas periodicamente nos postos de combustível.\n\nA data de coleta indica quando essas informações foram registradas pela agência.")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
            Text("Postos próximos")
                .font(.title2.bold())
                .foregroundStyle(AppTheme.Colors.textPrimary)

            StationsModePicker(selection: $selectedMode)

            if selectedMode == .nearby {
                Button {
                    viewModel.refresh()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin")
                            .font(.caption.weight(.semibold))

                        Text("Localização atual")
                            .font(.caption.weight(.medium))

                        Image(systemName: "arrow.clockwise")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(AppTheme.Colors.textMuted)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Atualizar postos pela localização atual")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if selectedMode == .favorites {
            favoritesContent
        } else if viewModel.locationPermissionDenied {
            StationsStateView(
                systemImage: "location.slash.fill",
                title: "Permissão de localização necessária",
                message: "Permissão de localização necessária para mostrar postos próximos.",
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
                message: errorMessage == "Não foi possível obter a localização." ? errorMessage : "Erro ao buscar postos. Verifique sua conexão.",
                buttonTitle: "Tentar novamente",
                action: viewModel.refresh
            )
        } else if viewModel.stations.isEmpty {
            StationsStateView(
                systemImage: "fuelpump.fill",
                title: "Nenhum posto encontrado",
                message: "Não encontramos postos cadastrados próximos à sua localização atual.",
                buttonTitle: "Atualizar",
                action: viewModel.refresh
            )
        } else {
            stationList(viewModel.stations)
        }
    }

    @ViewBuilder
    private var favoritesContent: some View {
        if favoriteStations.isEmpty {
            StationsStateView(
                systemImage: "heart",
                title: "Nenhum favorito ainda",
                message: "Abra um posto e toque no coração para salvá-lo aqui.",
                buttonTitle: "Ver postos próximos",
                action: {
                    selectedMode = .nearby
                }
            )
        } else {
            stationList(favoriteStations)
        }
    }

    private func stationList(_ stations: [FuelStation]) -> some View {
        LazyVStack(spacing: 0) {
            ForEach(stations) { station in
                StationRow(
                    station: station,
                    onInfoTapped: {
                        shouldShowCollectionInfo = true
                    },
                    onSelect: {
                        selectedStation = station
                    }
                )

                if station.id != stations.last?.id {
                    Divider()
                        .padding(.leading, 78)
                }
            }
        }
        .background(AppTheme.Colors.surface)
    }

    private func openNearbyStationsMap() {
        guard let url = viewModel.nearbyGasStationsMapsURL() else {
            return
        }

        openURL(url)
    }

    private func reloadFavorites() {
        favoriteStations = FavoriteStationsStore.favorites()
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        openURL(url)
    }
}

private enum StationsListMode: CaseIterable {
    case nearby
    case favorites

    var title: String {
        switch self {
        case .nearby: return "Próximos"
        case .favorites: return "Favoritos"
        }
    }
}

private struct StationsModePicker: View {
    @Binding var selection: StationsListMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(StationsListMode.allCases, id: \.self) { mode in
                Button {
                    selection = mode
                } label: {
                    Text(mode.title)
                        .font(.subheadline.weight(selection == mode ? .bold : .medium))
                        .foregroundStyle(selection == mode ? .white : AppTheme.Colors.textMuted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(selection == mode ? AppTheme.Colors.blue : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppTheme.Colors.background)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.control, style: .continuous))
    }
}

private struct StationRow: View {
    let station: FuelStation
    let onInfoTapped: () -> Void
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
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
            .contentShape(Rectangle())
            .onTapGesture(perform: onSelect)

            CollectionDateLabel(
                dateText: station.displayCollectionDate,
                onInfoTapped: onInfoTapped
            )
        }
        .padding(.vertical, 13)
        .padding(.horizontal, AppTheme.Spacing.medium)
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

private struct CollectionDateLabel: View {
    let dateText: String
    let onInfoTapped: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("Data de coleta: \(dateText)")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.textMuted)
                .lineLimit(1)

            Button(action: onInfoTapped) {
                Image(systemName: "info.circle")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Informações sobre os dados da ANP")

            Spacer(minLength: 0)
        }
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
        guard let value, value > 0 else {
            return "—"
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
