//
//  SettingsView.swift
//  PokerPotOdds
//
//  Created by Thomas Rakowski on 15.01.26.
//
import SwiftUI


struct SettingsView: View {
    @EnvironmentObject private var simulationManager: SimulationManager
    @AppStorage("selectedSimulationID") private var selectedSimulationID: String = ""
    
    private func idString(for kind: SimulationManager.StrategyKind) -> String {
        // Prefer the Identifiable id if it's a String; else stringify it
        if let stringID = kind.id as? String {
            return stringID
        } else {
            return String(describing: kind.id)
        }
    }
    
    private func kind(for idString: String) -> SimulationManager.StrategyKind? {
        SimulationManager.StrategyKind.allCases.first { candidate in
            if let stringID = candidate.id as? String {
                return stringID == idString
            } else {
                return String(describing: candidate.id) == idString
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Simulationen") {
                    Picker("Simulation", selection: $simulationManager.selected) {
                        ForEach(SimulationManager.StrategyKind.allCases) { kind in
                            Text(kind.displayName).tag(kind)
                        }
                    }
                    
                  
                }
                
                Section("Erklärungen") {
                    NavigationLink {
                        ChanceExplanationView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                            Text("Chance")
                        }
                    }
                    
                    NavigationLink {
                        MonteCarloExplanationView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                            Text("Monte‑Carlo‑Simulation")
                        }
                    }
                    
                    NavigationLink {
                        ExactOddsExplanationView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                            Text("Exakte Wahrscheinlichkeiten")
                        }
                    }
                    
                    NavigationLink {
                        HowToReadTableView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                            Text("Wie lese ich die Tabelle?")
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                if let restored = kind(for: selectedSimulationID) {
                    simulationManager.selected = restored
                } else {
                    // Fallback to a default value if none stored or not matched
                    if let first = SimulationManager.StrategyKind.allCases.first {
                        simulationManager.selected = first
                        selectedSimulationID = idString(for: first)
                    }
                }
            }
            .onChange(of: simulationManager.selected) { newValue in
                selectedSimulationID = idString(for: newValue)
            }
        }
    }
}
#Preview {
    SettingsView()
        .environmentObject(SimulationManager())
}

//struct ChanceExplanationView: View {
//    var body: some View {
//        Text("Chance Explanation Content")
//            .navigationTitle("Chance")
//    }
//}
struct MonteCarloExplanationView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("Monte‑Carlo‑Simulation")
                    .font(.title2).bold()
                
                Text("Bei der Monte‑Carlo‑Simulation werden viele zufällige Durchläufe simuliert. Aus den Treffern wird dann die Wahrscheinlichkeit geschätzt, wie oft ein Ereignis eintritt.")
                
                Text("Beispiel")
                    .font(.headline)
                
                Text("Wir ziehen 100.000 zufällige Flops und zählen, wie oft wir ein Paar treffen. Treffer/100.000 ≈ Chance.")
                    .font(.system(.body, design: .monospaced))
                    .padding(.vertical, 4)
                
                Text("• Vorteil: Einfache Implementierung und gute Approximation bei vielen Durchläufen.")
                Text("• Nachteil: Ergebnis ist eine Schätzung mit zufälliger Streuung.")
            }
            .padding()
        }
        .navigationTitle("Monte‑Carlo")
    }
}

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

