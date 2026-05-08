import SwiftUI

struct HistoryView: View {
    var body: some View {
        PlaceholderView(
            title: "Histórico de cálculos",
            message: "Os cálculos salvos neste aparelho vão aparecer aqui.",
            systemImage: "clock.arrow.circlepath"
        )
        .navigationTitle("Histórico")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
    }
}
