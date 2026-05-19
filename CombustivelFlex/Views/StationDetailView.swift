import SwiftUI

struct StationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var shouldShowCollectionInfo = false

    let station: FuelStation
    let mapsURL: URL?

    private let services = [
        StationService(systemImage: "gearshape.fill", title: "Troca de óleo"),
        StationService(systemImage: "tag.fill", title: "Conveniência"),
        StationService(systemImage: "car.fill", title: "Lavagem")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: AppTheme.Spacing.large) {
                detailCard
            }
            .padding(.horizontal, AppTheme.Spacing.large)
            .padding(.top, AppTheme.Spacing.medium)
            .padding(.bottom, 140)
        }
        .background(AppTheme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) {
            header
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            mapFooter
        }
        .alert("Dados da ANP", isPresented: $shouldShowCollectionInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Os preços exibidos são coletados pela ANP (Agência Nacional do Petróleo, Gás Natural e Biocombustíveis) e representam a média de preços praticados pelos postos na data indicada.")
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Voltar")

            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.top, AppTheme.Spacing.small)
        .padding(.bottom, AppTheme.Spacing.small)
        .background(AppTheme.Colors.background.opacity(0.96))
    }

    private var detailCard: some View {
        VStack(spacing: AppTheme.Spacing.large) {
            CollectionDateHeader(
                dateText: station.displayCollectionDate,
                onInfoTapped: {
                    shouldShowCollectionInfo = true
                }
            )
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: AppTheme.Spacing.medium) {
                StationDetailLogo(brand: station.brand)

                VStack(spacing: 4) {
                    Text(station.name)
                        .font(.headline.weight(.black))
                        .foregroundStyle(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)
                        .textCase(.uppercase)

                    Text("\(distanceText) de você")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textMuted)
                }
            }

            Divider()

            HStack(spacing: AppTheme.Spacing.medium) {
                DetailPriceCard(title: "Gasolina", value: station.regularGasolinePrice, tint: AppTheme.Colors.blue)
                DetailPriceCard(title: "Etanol", value: station.ethanolPrice, tint: AppTheme.Colors.green)
            }

            Divider()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Endereço")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                HStack(alignment: .top, spacing: AppTheme.Spacing.small) {
                    Image(systemName: "mappin")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.Colors.textMuted)
                        .frame(width: 18)

                    Text(station.address ?? "Endereço não informado")
                        .font(.caption)
                        .foregroundStyle(AppTheme.Colors.textSecondary)
                        .textCase(.uppercase)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.medium) {
                Text("Serviços disponíveis")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.small) {
                    ForEach(services) { service in
                        StationServiceCard(service: service)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AdMobBannerView(adUnitID: AdMobConfig.Banner.stationDetail, reservesTabBarClearance: false)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        }
        .padding(AppTheme.Spacing.large)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .shadow(color: .black.opacity(0.14), radius: 10, x: 0, y: 4)
    }

    private var mapFooter: some View {
        VStack(spacing: 0) {
            Button {
                if let mapsURL {
                    openURL(mapsURL)
                }
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
            .padding(.bottom, AppTheme.Spacing.medium)
        }
        .background(AppTheme.Colors.background.opacity(0.96))
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

private struct StationDetailLogo: View {
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
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 74, height: 74)
        .accessibilityLabel(brand.displayName)
    }
}

private struct DetailPriceCard: View {
    let title: String
    let value: Double?
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.caption)
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Text(priceText)
                .font(.title3.bold())
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.Spacing.medium)
        .background(AppTheme.Colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(AppTheme.Colors.divider, lineWidth: 1)
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

private struct StationService: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
}

private struct StationServiceCard: View {
    let service: StationService

    var body: some View {
        VStack(spacing: AppTheme.Spacing.small) {
            Image(systemName: service.systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textMuted)

            Text(service.title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 62)
        .background(Color(hex: 0xF3F5FA))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous)
                .stroke(AppTheme.Colors.divider, lineWidth: 1)
        }
    }
}

#Preview {
    StationDetailView(
        station: FuelStation(
            id: "preview",
            name: "Auto Posto Lutaif LTDA",
            brand: .shell,
            latitude: -23.55,
            longitude: -46.63,
            regularGasolinePrice: 6.49,
            additiveGasolinePrice: nil,
            ethanolPrice: 4.09,
            address: "Avenida Luiz Dumont Villares, 1159\nSantana - Sao Paulo - SP",
            updatedAt: nil,
            collectionDate: "15/05/2026",
            distanceMeters: 949
        ),
        mapsURL: nil
    )
}

private struct CollectionDateHeader: View {
    let dateText: String
    let onInfoTapped: () -> Void

    var body: some View {
        HStack(spacing: AppTheme.Spacing.small) {
            Text("Data de coleta: \(dateText)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)

            Button(action: onInfoTapped) {
                Image(systemName: "info.circle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.blue)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Informações sobre os dados da ANP")

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppTheme.Spacing.medium)
        .padding(.vertical, AppTheme.Spacing.small)
        .background(Color(hex: 0xF3F5FA))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.card, style: .continuous))
    }
}
