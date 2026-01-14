import SwiftUI

@MainActor struct PokerHandInfo: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let color: Color
}

@MainActor let allPokerHands: [PokerHandInfo] = [
    PokerHandInfo(title: "Royal Flush", description: "Ass bis Zehn in einer Farbe, die höchste Hand", color: .red),
    PokerHandInfo(title: "Straight Flush", description: "Fünf aufeinanderfolgende Karten in einer Farbe", color: .orange),
    PokerHandInfo(title: "Vierling", description: "Vier Karten gleichen Rangs", color: .yellow),
    PokerHandInfo(title: "Full House", description: "Drei gleiche Karten und ein Paar", color: .green),
    PokerHandInfo(title: "Flush", description: "Fünf Karten in einer Farbe", color: .blue),
    PokerHandInfo(title: "Straight", description: "Fünf aufeinanderfolgende Karten", color: .purple),
    PokerHandInfo(title: "Drilling", description: "Drei Karten gleichen Rangs", color: .pink),
    PokerHandInfo(title: "Zwei Paare", description: "Zwei verschiedene Paare", color: .gray),
    PokerHandInfo(title: "Ein Paar", description: "Zwei Karten gleichen Rangs", color: .brown),
    PokerHandInfo(title: "Hohe Karte", description: "Keine der obigen Kombinationen", color: .black)
]

@MainActor func pokerHandProbability(for handTitle: String, hero: [Card?], board: [Card?], opponents: Int, foldedOpponents: Int) -> Double {
    func clamp(_ value: Double, lower: Double, upper: Double) -> Double {
        if value < lower { return lower }
        if value > upper { return upper }
        return value
    }
    
    let heroCards = hero.compactMap { $0 }
    guard heroCards.count >= 2 else { return 0 }
    let first = heroCards[0]
    let second = heroCards[1]

    switch handTitle {
    case "Royal Flush":
        return clamp(Double(opponents - foldedOpponents) * 0.05, lower: 0, upper: 1)
    case "Straight Flush":
        return clamp(Double(opponents - foldedOpponents) * 0.04, lower: 0, upper: 1)
    case "Vierling":
        return clamp(Double(opponents - foldedOpponents) * 0.03, lower: 0, upper: 1)
    case "Full House":
        return clamp(Double(opponents - foldedOpponents) * 0.025, lower: 0, upper: 1)
    case "Flush":
        return clamp(Double(opponents - foldedOpponents) * 0.02, lower: 0, upper: 1)
    case "Straight":
        return clamp(Double(opponents - foldedOpponents) * 0.015, lower: 0, upper: 1)
    case "Drilling":
        return clamp(Double(opponents - foldedOpponents) * 0.01, lower: 0, upper: 1)
    case "Zwei Paare":
        return clamp(Double(opponents - foldedOpponents) * 0.008, lower: 0, upper: 1)
    case "Ein Paar":
        return clamp(Double(opponents - foldedOpponents) * 0.005, lower: 0, upper: 1)
    case "Hohe Karte":
        return clamp(Double(opponents - foldedOpponents) * 0.002, lower: 0, upper: 1)
    default:
        return 0
    }
}
