import SwiftUI

struct PokerHandsSheet: View {
    let hero: [Card?]
    let board: [Card?]
    let opponents: Int
    let foldedOpponents: Int

    private var hands: [PokerHandInfo] { allPokerHands }

    private func probability(for handTitle: String) -> Double {
        pokerHandProbability(for: handTitle, hero: hero, board: board, opponents: opponents, foldedOpponents: foldedOpponents)
    }

    var body: some View {
        NavigationStack {
            List(hands) { hand in
                HStack(spacing: 12) {
                    Circle()
                        .fill(hand.color.opacity(0.25))
                        .overlay(Circle().stroke(hand.color, lineWidth: 1))
                        .frame(width: 28, height: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(hand.title)
                            .font(.headline)
                        Text(hand.description)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(String(format: "%.1f%%", probability(for: hand.title)))
                        .font(.subheadline)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
            .navigationTitle("Pokerhände")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        // Dismiss via environment
                        dismiss()
                    }
                }
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
}

#Preview {
    PokerHandsSheet(hero: [Card(rank: .ace, suit: .spades), Card(rank: .king, suit: .spades)], board: [nil, nil, nil, nil, nil], opponents: 3, foldedOpponents: 1)
}
