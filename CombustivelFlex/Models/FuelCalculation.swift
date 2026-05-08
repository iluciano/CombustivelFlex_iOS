import Foundation

enum FuelType: String, Codable, Equatable {
    case gasoline
    case ethanol

    var displayName: String {
        switch self {
        case .gasoline: return "GASOLINA"
        case .ethanol: return "ETANOL"
        }
    }
}

struct FuelCalculationInput: Equatable {
    var gasolinePrice: Decimal
    var ethanolPrice: Decimal
    var gasolineConsumption: Decimal?
    var ethanolConsumption: Decimal?
}

struct FuelCalculationResult: Equatable {
    var recommendedFuel: FuelType
}
