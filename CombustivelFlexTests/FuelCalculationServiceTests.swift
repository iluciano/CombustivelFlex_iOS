import XCTest
@testable import CombustivelFlex

final class FuelCalculationServiceTests: XCTestCase {
    private let service = FuelCalculationService()

    func testCalculateWithPriceRatioRecommendsEthanolBelowSeventyPercent() throws {
        let result = try service.calculate(
            input: FuelCalculationInput(
                gasolinePrice: decimal("5.00"),
                ethanolPrice: decimal("3.40"),
                gasolineConsumption: nil,
                ethanolConsumption: nil
            )
        )

        XCTAssertEqual(result.recommendedFuel, .ethanol)
        XCTAssertEqual(result.basis, .priceRatio)
        XCTAssertEqual(result.priceRatio, decimal("0.68"))
        XCTAssertEqual(result.estimatedSavings, decimal("0.10"))
        XCTAssertNil(result.gasolineCostPerKilometer)
        XCTAssertNil(result.ethanolCostPerKilometer)
    }

    func testCalculateWithPriceRatioRecommendsGasolineAtSeventyPercent() throws {
        let result = try service.calculate(
            input: FuelCalculationInput(
                gasolinePrice: decimal("5.00"),
                ethanolPrice: decimal("3.50"),
                gasolineConsumption: nil,
                ethanolConsumption: nil
            )
        )

        XCTAssertEqual(result.recommendedFuel, .gasoline)
        XCTAssertEqual(result.basis, .priceRatio)
        XCTAssertEqual(result.priceRatio, decimal("0.70"))
        XCTAssertEqual(result.estimatedSavings, 0)
    }

    func testCalculateWithConsumptionRecommendsCheapestCostPerKilometer() throws {
        let result = try service.calculate(
            input: FuelCalculationInput(
                gasolinePrice: decimal("6.00"),
                ethanolPrice: decimal("4.00"),
                gasolineConsumption: decimal("10.00"),
                ethanolConsumption: decimal("8.00")
            )
        )

        XCTAssertEqual(result.recommendedFuel, .ethanol)
        XCTAssertEqual(result.basis, .consumption)
        XCTAssertNil(result.priceRatio)
        XCTAssertEqual(result.gasolineCostPerKilometer, decimal("0.60"))
        XCTAssertEqual(result.ethanolCostPerKilometer, decimal("0.50"))
        XCTAssertEqual(result.estimatedSavings, decimal("0.10"))
    }

    func testCalculateWithConsumptionCanRecommendGasoline() throws {
        let result = try service.calculate(
            input: FuelCalculationInput(
                gasolinePrice: decimal("5.70"),
                ethanolPrice: decimal("4.20"),
                gasolineConsumption: decimal("10.00"),
                ethanolConsumption: decimal("7.00")
            )
        )

        XCTAssertEqual(result.recommendedFuel, .gasoline)
        XCTAssertEqual(result.basis, .consumption)
        XCTAssertEqual(result.gasolineCostPerKilometer, decimal("0.57"))
        XCTAssertEqual(result.ethanolCostPerKilometer, decimal("0.60"))
        XCTAssertEqual(result.estimatedSavings, decimal("0.03"))
    }

    func testCalculateRejectsInvalidPrices() {
        XCTAssertThrowsError(
            try service.calculate(
                input: FuelCalculationInput(
                    gasolinePrice: 0,
                    ethanolPrice: decimal("3.40"),
                    gasolineConsumption: nil,
                    ethanolConsumption: nil
                )
            )
        ) { error in
            XCTAssertEqual(error as? FuelCalculationError, .invalidGasolinePrice)
        }

        XCTAssertThrowsError(
            try service.calculate(
                input: FuelCalculationInput(
                    gasolinePrice: decimal("5.00"),
                    ethanolPrice: 0,
                    gasolineConsumption: nil,
                    ethanolConsumption: nil
                )
            )
        ) { error in
            XCTAssertEqual(error as? FuelCalculationError, .invalidEthanolPrice)
        }
    }

    func testCalculateRejectsIncompleteConsumptionPair() {
        XCTAssertThrowsError(
            try service.calculate(
                input: FuelCalculationInput(
                    gasolinePrice: decimal("5.00"),
                    ethanolPrice: decimal("3.40"),
                    gasolineConsumption: decimal("10.00"),
                    ethanolConsumption: nil
                )
            )
        ) { error in
            XCTAssertEqual(error as? FuelCalculationError, .incompleteConsumptionPair)
        }
    }

    func testCalculateRejectsInvalidConsumptionValues() {
        XCTAssertThrowsError(
            try service.calculate(
                input: FuelCalculationInput(
                    gasolinePrice: decimal("5.00"),
                    ethanolPrice: decimal("3.40"),
                    gasolineConsumption: 0,
                    ethanolConsumption: decimal("8.00")
                )
            )
        ) { error in
            XCTAssertEqual(error as? FuelCalculationError, .invalidGasolineConsumption)
        }

        XCTAssertThrowsError(
            try service.calculate(
                input: FuelCalculationInput(
                    gasolinePrice: decimal("5.00"),
                    ethanolPrice: decimal("3.40"),
                    gasolineConsumption: decimal("10.00"),
                    ethanolConsumption: 0
                )
            )
        ) { error in
            XCTAssertEqual(error as? FuelCalculationError, .invalidEthanolConsumption)
        }
    }

    private func decimal(_ value: String) -> Decimal {
        Decimal(string: value)!
    }
}
