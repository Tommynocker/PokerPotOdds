import SwiftUI

struct ExactOddsExplanationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Exakte Wahrscheinlichkeiten")
                    .font(.title2).bold()
                
                Text("Hier werden alle möglichen Kartenkombinationen systematisch gezählt, um die exakte Chance zu berechnen.")
                
                Text("Beispiel")
                    .font(.headline)
                
                Text("Wir enumerieren alle möglichen Flops (C(50,3)) und zählen, in wie vielen Fällen ein Paar entsteht. Treffer/Anzahl = exakte Chance.")
                    .font(.system(.body, design: .monospaced))
                    .padding(.vertical, 4)
                
                Text("• Vorteil: Exakte Ergebnisse ohne Schätzung.")
                Text("• Nachteil: Oft deutlich komplexer und rechenintensiver.")
            }
            .padding()
        }
        .navigationTitle("Exakt")
    }
}

#Preview {
    NavigationStack {
        ExactOddsExplanationView()
    }
}
