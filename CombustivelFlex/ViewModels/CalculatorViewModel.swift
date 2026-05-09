import Foundation
import Combine

@MainActor
final class CalculatorViewModel: ObservableObject {
    @Published var gasolinePrice = ""
    @Published var ethanolPrice = ""
    @Published var gasolineConsumption = ""
    @Published var ethanolConsumption = ""
    @Published private(set) var result: FuelCalculationResult?
    @Published private(set) var errorMessage: String?

    private let calculationService = FuelCalculationService()
    private var lastInput: FuelCalculationInput?

    func calculate() -> Bool {
        guard
            let gasoline = Decimal(string: normalized(gasolinePrice)),
            let ethanol = Decimal(string: normalized(ethanolPrice))
        else {
            result = nil
            lastInput = nil
            errorMessage = "Informe preços válidos para gasolina e etanol."
            return false
        }

        let gasolineConsumptionValue: Decimal?
        let ethanolConsumptionValue: Decimal?

        do {
            gasolineConsumptionValue = try optionalDecimal(
                gasolineConsumption,
                invalidMessage: FuelCalculationError.invalidGasolineConsumption.userMessage
            )
            ethanolConsumptionValue = try optionalDecimal(
                ethanolConsumption,
                invalidMessage: FuelCalculationError.invalidEthanolConsumption.userMessage
            )
        } catch let error as CalculatorInputError {
            result = nil
            lastInput = nil
            errorMessage = error.message
            return false
        } catch {
            result = nil
            lastInput = nil
            errorMessage = "Não foi possível calcular. Revise os dados informados."
            return false
        }

        let input = FuelCalculationInput(
            gasolinePrice: gasoline,
            ethanolPrice: ethanol,
            gasolineConsumption: gasolineConsumptionValue,
            ethanolConsumption: ethanolConsumptionValue
        )

        do {
            result = try calculationService.calculate(input: input)
            lastInput = input
            errorMessage = nil
            return true
        } catch let error as FuelCalculationError {
            result = nil
            lastInput = nil
            errorMessage = error.userMessage
            return false
        } catch {
            result = nil
            lastInput = nil
            errorMessage = "Não foi possível calcular. Revise os dados informados."
            return false
        }
    }

    func makeHistoryItem() -> CalculationHistoryItem? {
        guard let lastInput, let result else {
            return nil
        }

        return CalculationHistoryItem(
            gasolinePrice: lastInput.gasolinePrice,
            ethanolPrice: lastInput.ethanolPrice,
            gasolineConsumption: lastInput.gasolineConsumption,
            ethanolConsumption: lastInput.ethanolConsumption,
            result: result.recommendedFuel,
            basis: result.basis,
            estimatedSavings: result.estimatedSavings
        )
    }

    func defaultConsumptionCandidate() -> (gasoline: String, ethanol: String)? {
        let gasoline = completedConsumption(gasolineConsumption)
        let ethanol = completedConsumption(ethanolConsumption)

        guard !gasoline.isEmpty, !ethanol.isEmpty else {
            return nil
        }

        return (gasoline, ethanol)
    }

    func clear() {
        gasolinePrice = ""
        ethanolPrice = ""
        gasolineConsumption = ""
        ethanolConsumption = ""
        result = nil
        lastInput = nil
        errorMessage = nil
    }

    func applyDefaultConsumption(gasoline: String, ethanol: String) {
        if gasolineConsumption.isEmpty {
            gasolineConsumption = gasoline
        }

        if ethanolConsumption.isEmpty {
            ethanolConsumption = ethanol
        }
    }

    private func normalized(_ value: String) -> String {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: ".")

        if trimmedValue.hasSuffix(".") {
            return "\(trimmedValue)00"
        }

        return trimmedValue
    }

    private func optionalDecimal(_ value: String, invalidMessage: String) throws -> Decimal? {
        let normalizedValue = normalized(value)

        guard !normalizedValue.isEmpty else {
            return nil
        }

        guard let decimal = Decimal(string: normalizedValue) else {
            throw CalculatorInputError(message: invalidMessage)
        }

        return decimal
    }

    private func completedConsumption(_ value: String) -> String {
        let digits = value.filter(\.isNumber).prefix(4)

        guard !digits.isEmpty else {
            return ""
        }

        switch digits.count {
        case 1:
            return "\(digits).00"
        case 2, 3:
            let integerDigit = digits.prefix(1)
            let decimalDigits = digits.dropFirst(1)
            let completedDecimalDigits = String(decimalDigits).padding(toLength: 2, withPad: "0", startingAt: 0)

            return "\(integerDigit).\(completedDecimalDigits)"
        default:
            let integerDigits = digits.prefix(2)
            let decimalDigits = digits.dropFirst(2)

            return "\(integerDigits).\(decimalDigits)"
        }
    }
}

private struct CalculatorInputError: Error {
    let message: String
}
