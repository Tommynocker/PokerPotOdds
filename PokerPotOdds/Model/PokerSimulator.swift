import Foundation

struct SimulationResult {
    let handCategoryCounts: [HandCategory: Int]
    let iterations: Int
}

actor PokerSimulator {
    init() {}
    
    func simulate(
        hero: [Card?],
        board: [Card?],
        activeOpponents: Int,
        iterations: Int,
        rng: inout any RandomNumberGenerator
    ) async -> SimulationResult {
        // Compact hero and board removing nils
        let heroCards = hero.compactMap { $0 }
        let boardCards = board.compactMap { $0 }
        
        // Validate hero has exactly 2 cards
        guard heroCards.count == 2 else {
            return SimulationResult(handCategoryCounts: [:], iterations: 0)
        }
        
        // Validate board count is between 0 and 5 inclusive
        guard boardCards.count <= 5 else {
            return SimulationResult(handCategoryCounts: [:], iterations: 0)
        }
        
        // Build deck: full deck minus hero and board cards
        var deck = fullDeck()
        deck.removeAll(where: { card in
            heroCards.contains(card) || boardCards.contains(card)
        })
        
        var counts: [HandCategory: Int] = [:]
        
        for _ in 0..<iterations {
            // Shuffle a copy of deck
            var deckCopy = deck
            deckCopy.shuffle(using: &rng)
            
            var index = 0
            
            // Deal 2 cards per active opponent
            // Note: Opponent cards are not used here except to simulate unknown cards
            index += activeOpponents * 2
            
            // Deal remaining board cards to reach 5 total
            let remainingBoardCount = 5 - boardCards.count
            guard remainingBoardCount >= 0 else {
                continue // Should not happen due to guard above
            }
            let dealtBoardCards = deckCopy[index..<(index + remainingBoardCount)]
            index += remainingBoardCount
            
            // Assemble full board for evaluation
            let fullBoard = boardCards + dealtBoardCards
            
            // Evaluate hero best category
            let category = evaluateBestCategory(hero: heroCards, board: fullBoard)
            
            counts[category, default: 0] += 1
        }
        
        return SimulationResult(handCategoryCounts: counts, iterations: iterations)
    }
}

func fullDeck() -> [Card] {
    var deck: [Card] = []
    for suit in Suit.allCases {
        for rank in Rank.allCases {
            deck.append(Card(rank: rank, suit: suit))
        }
    }
    return deck
}
