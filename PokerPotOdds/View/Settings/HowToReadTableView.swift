import SwiftUI

struct HowToReadTableView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Wie lese ich die Tabelle?")
                    .font(.title2).bold()
                
                Text("Die Liste bzw. Tabelle zeigt die finale Verteilung deiner Handkategorien bis zum River (ausgehend vom aktuellen Board/Hand). Jeder Prozentwert bedeutet: In so vielen Durchläufen endet deine finale Hand in dieser Kategorie.")
                
                Text("Beispiel")
                    .font(.headline)
                
                Image("PrognoseBeispiel")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                    .shadow(radius: 1)
                
                Text("Ein Paar 43%, Zwei Paare 22%, Hohe Karte 18%, Straight 7%  |  Chance 82%")
                    .font(.system(.body, design: .monospaced))
                    .padding(.vertical, 4)
                
                Text("Bedeutung: Ausgehend vom aktuellen Zustand endet deine Hand in 43% der Durchläufe als Ein Paar, in 22% als Zwei Paare, in 18% als Hohe Karte und in 7% als Straight. Die Zeile \"Chance\" (82%) fasst zusammen, wie oft sich deine Hand von jetzt an noch verbessert – hier also die Gesamtwahrscheinlichkeit, am Ende besser dazustehen als im Moment.")
                
                Text("• Finale Verteilung vs. Rest‑Chance: Die Prozentwerte sind final (am River), nicht die Wahrscheinlichkeit, sich von jetzt an noch zu verbessern.")
                Text("• Bereits erreicht: Wenn eine Kategorie jetzt schon wahr ist, kann sie trotzdem mit einem Prozentanteil erscheinen, weil du am Ende immer noch in dieser Kategorie landen kannst.")
                Text("• Kontext: Die Werte hängen vom aktuellen Board, deinen Karten und der Anzahl aktiver Gegner ab.")
                
                Text("Nutze die größten Prozentwerte, um ein Gefühl zu bekommen, wie deine Hand typischerweise am Ende aussieht, und die Verbesserungshinweise (Chance), um zu sehen, wie oft es noch besser wird.")
            }
            .padding()
        }
        .navigationTitle("Tabelle lesen")
    }
}

#Preview {
    NavigationStack { HowToReadTableView() }
}
