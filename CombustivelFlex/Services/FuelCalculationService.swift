import Foundation

struct FuelCalculationService {
    private let ethanolEfficiencyRatio = Decimal(sign: .plus, exponent: -1, significand: 7)

    func calculate(input: FuelCalculationInput) throws -> FuelCalculationResult {
        try validatePrices(input)

        switch (input.gasolineConsumption, input.ethanolConsumption) {
        case (.none, .none):
            return calculateByPriceRatio(input)
        case (.some(let gasolineConsumption), .some(let ethanolConsumption)):
            try validateConsumption(
                gasolineConsumption: gasolineConsumption,
                ethanolConsumption: ethanolConsumption
            )
            return calculateByConsumption(
                input: input,
                gasolineConsumption: gasolineConsumption,
                ethanolConsumption: ethanolConsumption
            )
        default:
            throw FuelCalculationError.incompleteConsumptionPair
        }
    }

    private func calculateByPriceRatio(_ input: FuelCalculationInput) -> FuelCalculationResult {
        let priceRatio = input.ethanolPrice / input.gasolinePrice
        let breakEvenEthanolPrice = input.gasolinePrice * ethanolEfficiencyRatio
        let recommendedFuel: FuelType = priceRatio < ethanolEfficiencyRatio ? .ethanol : .gasoline

        return FuelCalculationResult(
            recommendedFuel: recommendedFuel,
            basis: .priceRatio,
            priceRatio: priceRatio,
            gasolineCostPerKilometer: nil,
            ethanolCostPerKilometer: nil,
            estimatedSavings: absolute(breakEvenEthanolPrice - input.ethanolPrice)
        )
    }

    private func calculateByConsumption(
        input: FuelCalculationInput,
        gasolineConsumption: Decimal,
        ethanolConsumption: Decimal
    ) -> FuelCalculationResult {
        let gasolineCostPerKilometer = input.gasolinePrice / gasolineConsumption
        let ethanolCostPerKilometer = input.ethanolPrice / ethanolConsumption
        let recommendedFuel: FuelType = ethanolCostPerKilometer < gasolineCostPerKilometer ? .ethanol : .gasoline

        return FuelCalculationResult(
            recommendedFuel: recommendedFuel,
            basis: .consumption,
            priceRatio: nil,
            gasolineCostPerKilometer: gasolineCostPerKilometer,
            ethanolCostPerKilometer: ethanolCostPerKilometer,
            estimatedSavings: absolute(gasolineCostPerKilometer - ethanolCostPerKilometer)
        )
    }

    private func validatePrices(_ input: FuelCalculationInput) throws {
        guard input.gasolinePrice > 0 else {
            throw FuelCalculationError.invalidGasolinePrice
        }

        guard input.ethanolPrice > 0 else {
            throw FuelCalculationError.invalidEthanolPrice
        }
    }

    private func validateConsumption(
        gasolineConsumption: Decimal,
        ethanolConsumption: Decimal
    ) throws {
        guard gasolineConsumption > 0 else {
            throw FuelCalculationError.invalidGasolineConsumption
        }

        guard ethanolConsumption > 0 else {
            throw FuelCalculationError.invalidEthanolConsumption
        }
    }

    private func absolute(_ value: Decimal) -> Decimal {
        value < 0 ? value * -1 : value
    }
}
