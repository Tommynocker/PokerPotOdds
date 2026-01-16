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
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("prognosisHapticsEnabled") private var prognosisHapticsEnabled: Bool = false
    @AppStorage("simulationAutoStartMode") private var simulationAutoStartMode: String = "completeStreets"
    
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
            VStack(spacing: 0) {
                Form {
                    Section("Einstellungen") {
                        Picker("Simulation", selection: $simulationManager.selected) {
                            ForEach(SimulationManager.StrategyKind.allCases) { kind in
                                Text(kind.displayName).tag(kind)
                            }
                        }
                        Toggle(isOn: $hapticsEnabled) {
                            Text("Karten‑Haptik")
                        }
                        .tint(.accentColor)
                        Toggle(isOn: $prognosisHapticsEnabled) {
                            Text("Prognose‑Haptik")
                        }
                        .tint(.accentColor)
                        Toggle(isOn: .init(
                            get: { simulationAutoStartMode == "completeStreets" },
                            set: { simulationAutoStartMode = $0 ? "completeStreets" : "always" }
                        )) {
                            Text("Nur bei vollständigen Streets starten")
                        }
                        .tint(.accentColor)
                        Text(simulationAutoStartMode == "completeStreets" ? "Simuliert automatisch, wenn beide Hole Cards vorhanden sind bzw. Flop/Turn/River vollständig liegen." : "Simuliert automatisch bei jeder Änderung an Hand oder Board.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Inline banner between sections
                    Section {
                        BannerView()
                            .frame(maxWidth: .infinity)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                    }
                    
                    Section("Erklärungen") {
                        NavigationLink {
                            HowToReadTableView()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .foregroundStyle(.secondary)
                                Text("Wie lese ich die Tabelle?")
                            }
                        }
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
                                Image(systemName: "chart.dots.scatter")
                                    .foregroundStyle(.secondary)
                                Text("Monte‑Carlo‑Simulation")
                            }
                        }
                        NavigationLink {
                            HeuristicExplanationView()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "lightbulb")
                                    .foregroundStyle(.secondary)
                                Text("Heuristik")
                            }
                        }
                        NavigationLink {
                            ExactOddsExplanationView()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "percent")
                                    .foregroundStyle(.secondary)
                                Text("Exact Odds")
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .onAppear {
                    if let restored = kind(for: selectedSimulationID) {
                        simulationManager.selected = restored
                    } else {
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
}

private struct BannerView: View {
    var body: some View {
        Text("Werbebanner")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(.thinMaterial)
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

