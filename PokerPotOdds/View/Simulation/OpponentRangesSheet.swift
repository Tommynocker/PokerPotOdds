//
//  OpponentRangesSheet.swift
//  PokerPotOdds
//
//  Created by Thomas Rakowski on 16.01.26.
//

import SwiftUI

// MARK: - Model

enum RangePreset: String, CaseIterable, Identifiable {
    case random = "Random"
    case tight = "Tight"
    case standard = "Standard"
    case loose = "Loose"
    case custom = "Custom"

    var id: String { rawValue }

    var approxPercent: Int? {
        switch self {
        case .random: return nil
        case .tight: return 15
        case .standard: return 25
        case .loose: return 40
        case .custom: return nil
        }
    }

    var help: String {
        switch self {
        case .random: return "Zufällige Hände (unrealistisch, aber Referenz)."
        case .tight: return "Wenige, starke Hände."
        case .standard: return "Typische spielbare Auswahl."
        case .loose: return "Viele Hände inkl. suited/connected."
        case .custom: return "Du legst die Range-% fest."
        }
    }
}

struct OpponentRange: Identifiable, Equatable {
    let id: UUID = UUID()
    var preset: RangePreset = .standard
    var customPercent: Double = 25
}

// MARK: - Sheet View

struct OpponentRangesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let opponentCount: Int

    /// Persisted ranges in your main screen
    @Binding var ranges: [OpponentRange]

    // Local editable copy (commit on Save)
    @State private var draft: [OpponentRange] = []

    // Quick actions
    @State private var applyAllPreset: RangePreset = .standard
    @State private var applyAllCustomPercent: Double = 25

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Gegner")
                        Spacer()
                        Text("\(opponentCount)")
                            .foregroundStyle(.secondary)
                    }

                    // Quick apply row
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Auf alle anwenden")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Picker("Preset", selection: $applyAllPreset) {
                            ForEach(RangePreset.allCases) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)

                        if applyAllPreset == .custom {
                            percentSlider(title: "Range", percent: $applyAllCustomPercent)
                        } else if let p = applyAllPreset.approxPercent {
                            Text("≈ \(p)% der Hände")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        Button {
                            applyToAll()
                        } label: {
                            Label("Übernehmen", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.vertical, 4)
                }

                Section("Individuelle Gegner-Ranges") {
                    ForEach(draft.indices, id: \.self) { i in
                        opponentRow(index: i)
                    }
                }

                Section("Zusammenfassung") {
                    Text(summaryText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Gegner-Ranges")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        ranges = draft
                        dismiss()
                    }
                }
            }
            .onAppear {
                draft = normalized(ranges, to: opponentCount)
            }
        }
    }

    // MARK: - Rows

    @ViewBuilder
    private func opponentRow(index i: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Gegner \(i + 1)")
                    .font(.headline)

                Spacer()

                Menu {
                    ForEach(RangePreset.allCases) { p in
                        Button {
                            draft[i].preset = p
                            if p != .custom, let ap = p.approxPercent {
                                draft[i].customPercent = Double(ap)
                            }
                        } label: {
                            Label(p.rawValue, systemImage: draft[i].preset == p ? "checkmark" : "")
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(draft[i].preset.rawValue)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if draft[i].preset == .custom {
                percentSlider(title: "Range", percent: $draft[i].customPercent)
            } else if let p = draft[i].preset.approxPercent {
                Text("≈ \(p)% der Hände")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Text(draft[i].preset.help)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }

    private func percentSlider(title: String, percent: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                Spacer()
                Text("\(Int(percent.wrappedValue))%")
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            Slider(value: percent, in: 5...60, step: 1)
        }
    }

    // MARK: - Helpers

    private func applyToAll() {
        for i in draft.indices {
            draft[i].preset = applyAllPreset
            if applyAllPreset == .custom {
                draft[i].customPercent = applyAllCustomPercent
            } else if let ap = applyAllPreset.approxPercent {
                draft[i].customPercent = Double(ap)
            }
        }
    }

    private var summaryText: String {
        let parts = draft.enumerated().map { i, r -> String in
            if r.preset == .custom {
                return "G\(i+1): Custom \(Int(r.customPercent))%"
            } else if let ap = r.preset.approxPercent {
                return "G\(i+1): \(r.preset.rawValue) (≈\(ap)%)"
            } else {
                return "G\(i+1): Random"
            }
        }
        return parts.joined(separator: " • ")
    }

    private func normalized(_ input: [OpponentRange], to n: Int) -> [OpponentRange] {
        if input.count == n { return input }
        if input.count > n { return Array(input.prefix(n)) }
        return input + Array(repeating: OpponentRange(), count: n - input.count)
    }
}

// MARK: - Example usage (drop into your main screen)

struct RangeSheetDemoHost: View {
    @State private var opponents: Int = 3
    @State private var ranges: [OpponentRange] = Array(repeating: OpponentRange(), count: 3)
    @State private var showSheet = false

    var body: some View {
        VStack(spacing: 16) {
            Stepper("Gegner: \(opponents)", value: $opponents, in: 1...8)
                .padding(.horizontal)
                .onChange(of: opponents) { newValue in
                    // keep ranges array in sync with opponent count
                    if ranges.count > newValue {
                        ranges = Array(ranges.prefix(newValue))
                    } else if ranges.count < newValue {
                        ranges += Array(repeating: OpponentRange(), count: newValue - ranges.count)
                    }
                }

            Button("Gegner-Ranges bearbeiten") {
                showSheet = true
            }
            .buttonStyle(.borderedProminent)

            Text("Aktuell: \(rangesSummary(ranges))")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showSheet) {
            OpponentRangesSheet(opponentCount: opponents, ranges: $ranges)
                .presentationDetents([.medium, .large])
        }
    }

    private func rangesSummary(_ r: [OpponentRange]) -> String {
        r.enumerated().map { i, x in
            if x.preset == .custom { return "G\(i+1): \(Int(x.customPercent))%" }
            return "G\(i+1): \(x.preset.rawValue)"
        }.joined(separator: " • ")
    }
}

#Preview {
    RangeSheetDemoHost()
}
