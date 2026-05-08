import SwiftUI

struct PlaceholderView: View {
    let title: String
    let message: String
    let systemImage: String

    var body: some View {
        VStack(spacing: AppTheme.Spacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(AppTheme.Colors.blue)

            Text(title)
                .font(.title2.bold())
                .foregroundStyle(AppTheme.Colors.textPrimary)

            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.Colors.textSecondary)
                .padding(.horizontal, AppTheme.Spacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.background)
    }
}

#Preview {
    PlaceholderView(
        title: "Postos próximos",
        message: "Funcionalidade em breve.",
        systemImage: "fuelpump"
    )
}
