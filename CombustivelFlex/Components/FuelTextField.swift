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

                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .textInputAutocapitalization(.never)
                    .focused($isFocused)
                    .onChange(of: text) { _, newValue in
                        let maskedValue = masked(newValue)

                        if maskedValue != newValue {
                            text = maskedValue
                        }
                    }
                    .onChange(of: isFocused) { _, isFocused in
                        guard !isFocused else {
                            return
                        }

                        text = completed(text)
                    }
            }
        }
    }

    private func masked(_ value: String) -> String {
        let digits = value.filter(\.isNumber).prefix(4)

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

    private func completed(_ value: String) -> String {
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
