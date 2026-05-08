import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            NavigationLink {
                PlaceholderView(
                    title: "Dicas de economia",
                    message: "As dicas serão migradas do app Android nas próximas etapas.",
                    systemImage: "lightbulb"
                )
                .navigationTitle("Dicas")
            } label: {
                FeatureRow(title: "Dicas de economia", subtitle: "Aprenda a economizar combustível", systemImage: "lightbulb")
            }

            NavigationLink {
                PlaceholderView(
                    title: "Configurações",
                    message: "Preferências de consumo, unidade e notificações entram aqui.",
                    systemImage: "gearshape"
                )
                .navigationTitle("Configurações")
            } label: {
                FeatureRow(title: "Configurações", subtitle: "Personalize suas preferências", systemImage: "gearshape")
            }
        }
        .navigationTitle("Mais")
    }
}

#Preview {
    NavigationStack {
        MoreView()
    }
}
