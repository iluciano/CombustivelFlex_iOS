import Foundation

struct CalculationHistoryItem: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var gasolinePrice: Decimal
    var ethanolPrice: Decimal
    var gasolineConsumption: Decimal?
    var ethanolConsumption: Decimal?
    var result: FuelType
    var basis: FuelCalculationBasis
    var estimatedSavings: Decimal

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        gasolinePrice: Decimal,
        ethanolPrice: Decimal,
        gasolineConsumption: Decimal? = nil,
        ethanolConsumption: Decimal? = nil,
        result: FuelType,
        basis: FuelCalculationBasis,
        estimatedSavings: Decimal
    ) {
        self.id = id
        self.createdAt = createdAt
        self.gasolinePrice = gasolinePrice
        self.ethanolPrice = ethanolPrice
        self.gasolineConsumption = gasolineConsumption
        self.ethanolConsumption = ethanolConsumption
        self.result = result
        self.basis = basis
        self.estimatedSavings = estimatedSavings
    }
}
