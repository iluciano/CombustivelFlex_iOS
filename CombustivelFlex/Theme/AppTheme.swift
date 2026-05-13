import SwiftUI
import UIKit

enum AppTheme {
    enum Colors {
        static let background = Color(hex: 0xF6F8FC)
        static let surface = Color.white
        static let textPrimary = Color(hex: 0x101828)
        static let textSecondary = Color(hex: 0x475467)
        static let textMuted = Color(hex: 0x98A2B3)
        static let divider = Color(hex: 0xE4E7EC)
        static let blue = Color(hex: 0x1473F8)
        static let orange = Color(hex: 0xFF7A00)
        static let green = Color(hex: 0x0F9F5A)
        static let greenLight = Color(hex: 0xECFDF3)
    }

    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }

    enum Radius {
        static let card: CGFloat = 8
        static let control: CGFloat = 8
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension UIColor {
    convenience init(hex: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
