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

enum FuelCalculationBasis: String, Codable, Equatable {
    case priceRatio
    case consumption
}

struct FuelCalculationInput: Equatable {
    var gasolinePrice: Decimal
    var ethanolPrice: Decimal
    var gasolineConsumption: Decimal?
    var ethanolConsumption: Decimal?
}

struct FuelCalculationResult: Equatable {
    var recommendedFuel: FuelType
    var basis: FuelCalculationBasis
    var priceRatio: Decimal?
    var gasolineCostPerKilometer: Decimal?
    var ethanolCostPerKilometer: Decimal?
    var estimatedSavings: Decimal
}

enum FuelCalculationError: Error, Equatable {
    case invalidGasolinePrice
    case invalidEthanolPrice
    case incompleteConsumptionPair
    case invalidGasolineConsumption
    case invalidEthanolConsumption
}

extension FuelCalculationError {
    var userMessage: String {
        switch self {
        case .invalidGasolinePrice:
            return "Informe um preço de gasolina maior que zero."
        case .invalidEthanolPrice:
            return "Informe um preço de etanol maior que zero."
        case .incompleteConsumptionPair:
            return "Informe os dois consumos ou deixe os dois em branco."
        case .invalidGasolineConsumption:
            return "Informe um consumo de gasolina maior que zero."
        case .invalidEthanolConsumption:
            return "Informe um consumo de etanol maior que zero."
        }
    }
}
