import SwiftUI

struct ChanceExplanationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Was bedeutet die Chance?")
                    .font(.title2)
                    .bold()

                Text("Die Prozentangabe bei \"Chance\" zeigt, wie hoch die Wahrscheinlichkeit ist, dass sich deine Hand bis zum Showdown verbessert.\n\n• Wenn du aktuell noch kein Paar hast: Es ist die Wahrscheinlichkeit, bis zum Showdown mindestens ein Paar oder besser zu erreichen (Ein Paar, Zwei Paare, Drilling, Straight, Flush, Full House, Vierling, Straight Flush, Royal Flush).\n\n• Wenn du aktuell bereits ein Paar hast: Es ist die Wahrscheinlichkeit, bis zum Showdown eine bessere Hand als ein Paar zu erreichen (Zwei Paare, Drilling, Straight, Flush, Full House, Vierling, Straight Flush, Royal Flush).")
                    .font(.body)

                Text("Wie wird die Chance berechnet?")
                    .font(.headline)

                Text("Die App führt eine Simulation durch und zählt, wie oft jede Handkategorie am Ende erreicht wurde. Daraus werden Prozentwerte berechnet. Je nach aktuellem Status (schon Paar oder nicht) werden die relevanten Kategorien aufsummiert und als \"Chance\" angezeigt.")
                    .font(.body)

                Text("Beispiel")
                    .font(.headline)

                Text("• Du hast noch kein Paar → Chance = 42,7%: In etwa 42,7% der simulierten Durchläufe erreichst du am Ende mindestens ein Paar.\n\n• Du hast bereits ein Paar → Chance = 18,3%: In etwa 18,3% der simulierten Durchläufe verbesserst du dich auf besser als ein Paar (z. B. Zwei Paare, Drilling, etc.).")
                    .font(.body)
                    
            }
            .padding()
        }
        .navigationTitle("Chance")
    }
}

#Preview {
    NavigationStack { ChanceExplanationView() }
}
