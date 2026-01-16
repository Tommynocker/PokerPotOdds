//
//  MonteCarloExplanationView.swift
//  PokerPotOdds
//
//  Created by Thomas Rakowski on 15.01.26.
//

import SwiftUI

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

#Preview {
    MonteCarloExplanationView()
}
