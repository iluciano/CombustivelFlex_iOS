import Foundation
import Combine

@MainActor
final class CalculatorViewModel: ObservableObject {
    @Published var gasolinePrice = ""
    @Published var ethanolPrice = ""
    @Published var gasolineConsumption = ""
    @Published var ethanolConsumption = ""
    @Published private(set) var result: FuelCalculationResult?

    private let calculationService = FuelCalculationService()

    func calculate() -> Bool {
        guard
            let gasoline = Decimal(string: normalized(gasolinePrice)),
            let ethanol = Decimal(string: normalized(ethanolPrice)),
            gasoline > 0,
            ethanol > 0
        else {
            result = nil
            return false
        }

        let input = FuelCalculationInput(
            gasolinePrice: gasoline,
            ethanolPrice: ethanol,
            gasolineConsumption: Decimal(string: normalized(gasolineConsumption)),
            ethanolConsumption: Decimal(string: normalized(ethanolConsumption))
        )
        result = calculationService.calculate(input: input)
        return true
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")
    }
}
