import SwiftUI

struct StationsView: View {
    var body: some View {
        PlaceholderView(
            title: "Postos próximos",
            message: "Em breve você poderá encontrar postos perto de você.",
            systemImage: "fuelpump"
        )
        .navigationTitle("Postos")
    }
}

#Preview {
    NavigationStack {
        StationsView()
    }
}
