import SwiftUI

struct HeuristicExplanationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Heuristisches Modell")
                    .font(.title)
                    .bold()
                
                Text("Das heuristische Modell ist ein einfacher Ansatz zur Entscheidungsfindung, der auf Faustregeln basiert, statt auf komplexen Berechnungen.")
                    .font(.body)
                
                Text("Vorteile:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Schnell und einfach anzuwenden")
                    Text("• Benötigt wenig Informationen")
                    Text("• Praktisch in Alltagssituationen")
                }
                
                Text("Nachteile:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Nicht immer präzise")
                    Text("• Kann zu Fehleinschätzungen führen")
                    Text("• Berücksichtigt selten alle Faktoren")
                }
                
                Text("Beispiel:")
                    .font(.headline)
                Text("Wenn Sie entscheiden müssen, ob Sie einen Regenschirm mitnehmen, ohne die exakte Wettervorhersage zu kennen, könnten Sie eine Heuristik verwenden: „Wenn der Himmel bewölkt ist, nehme ich einen Regenschirm mit.“ Diese einfache Regel ist schnell anzuwenden, auch wenn sie nicht immer korrekt ist.")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Heuristisches Modell")
    }
}

#Preview {
    NavigationStack {
        HeuristicExplanationView()
    }
}
