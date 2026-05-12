import SwiftUI

struct FuelTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let tint: Color
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.small) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.Colors.textSecondary)

            HStack {
                Circle()
                    .fill(tint)
                    .frame(width: 10, height: 10)

                TextField(
                    text: $text,
                    prompt: Text(placeholder)
                        .foregroundStyle(AppTheme.Colors.textMuted)
                ) {
                    Text(placeholder)
                }
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(AppTheme.Colors.textPrimary)
                    .tint(AppTheme.Colors.blue)
                    .focused($isFocused)
                    .onChange(of: text) { oldValue, newValue in
                        let maskedValue = NumericInputMask.masked(newValue, previousValue: oldValue)

                        if maskedValue != newValue {
                            text = maskedValue
                        }
                    }
                    .onChange(of: isFocused) { _, isFocused in
                        guard !isFocused else {
                            return
                        }

                        text = NumericInputMask.completed(text)
                    }
            }
        }
    }
}

enum NumericInputMask {
    static func masked(_ value: String, previousValue: String = "") -> String {
        let valueForMasking = valueForMasking(value, previousValue: previousValue)
        let digits = valueForMasking.filter(\.isNumber).prefix(4)

        guard !digits.isEmpty else {
            return ""
        }

        switch digits.count {
        case 1:
            return "\(digits)."
        case 2, 3:
            let integerDigit = digits.prefix(1)
            let decimalDigits = digits.dropFirst(1)

            return "\(integerDigit).\(decimalDigits)"
        default:
            let integerDigits = digits.prefix(2)
            let decimalDigits = digits.dropFirst(2)

            return "\(integerDigits).\(decimalDigits)"
        }
    }

    static func completed(_ value: String) -> String {
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

    static func normalizedDecimal(_ value: String) -> String {
        let trimmedValue = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        if trimmedValue.hasSuffix(".") {
            return "\(trimmedValue)00"
        }

        return trimmedValue
    }

    private static func valueForMasking(_ value: String, previousValue: String) -> String {
        guard value.count < previousValue.count else {
            return value
        }

        if previousValue.hasSuffix("."),
           value == String(previousValue.dropLast()) {
            return String(value.dropLast())
        }

        let previousDigits = previousValue.filter(\.isNumber)
        let currentDigits = value.filter(\.isNumber)

        guard previousValue.contains("."),
              !value.contains("."),
              previousDigits == currentDigits,
              let separatorIndex = previousValue.firstIndex(of: ".")
        else {
            return value
        }

        let digitsBeforeSeparator = previousValue[..<separatorIndex].filter(\.isNumber).count

        guard digitsBeforeSeparator > 0 else {
            return value
        }

        var digits = Array(currentDigits)
        digits.remove(at: digitsBeforeSeparator - 1)

        return String(digits)
    }
}
