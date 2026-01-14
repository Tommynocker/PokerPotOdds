import Foundation

// Assume existing types:
// struct Card { let rank: Rank; let suit: Suit }
// enum Rank: Int { case two = 2, three, four, five, six, seven, eight, nine, ten, jack, queen, king, ace }
// enum Suit: Int { case clubs, diamonds, hearts, spades }

enum HandCategory: Int, CaseIterable {
    case highCard = 0
    case onePair
    case twoPair
    case threeOfAKind
    case straight
    case flush
    case fullHouse
    case fourOfAKind
    case straightFlush
    case royalFlush
}

func evaluateBestCategory(hero: [Card], board: [Card]) -> HandCategory {
    let allCards = hero + board
    if allCards.count < 5 {
        return .highCard
    }
    
    let fiveCardHands = combinations(from: allCards, choose: 5)
    var bestCategory: HandCategory = .highCard
    
    for hand in fiveCardHands {
        let category = evaluateCategory(of: hand)
        if category.rawValue > bestCategory.rawValue {
            bestCategory = category
        }
    }
    
    return bestCategory
}

private func evaluateCategory(of five: [Card]) -> HandCategory {
    let flush = isFlush(five)
    let straight = isStraight(five)
    let counts = rankCounts(five)
    let countValues = counts.values.sorted(by: >) // Descending
    
    if flush && straight {
        // Check if highest rank is Ace for royal flush
        let ranks = five.map { $0.rank.rawValue }
        if ranks.contains(14) && ranks.contains(13) && ranks.contains(12) && ranks.contains(11) && ranks.contains(10) {
            return .royalFlush
        }
        return .straightFlush
    }
    
    if countValues == [4,1] {
        return .fourOfAKind
    }
    
    if countValues == [3,2] {
        return .fullHouse
    }
    
    if flush {
        return .flush
    }
    
    if straight {
        return .straight
    }
    
    if countValues == [3,1,1] {
        return .threeOfAKind
    }
    
    if countValues == [2,2,1] {
        return .twoPair
    }
    
    if countValues == [2,1,1,1] {
        return .onePair
    }
    
    return .highCard
}

func isFlush(_ five: [Card]) -> Bool {
    guard let firstSuit = five.first?.suit else { return false }
    return five.allSatisfy { $0.suit == firstSuit }
}

func isStraight(_ five: [Card]) -> Bool {
    let ranks = five.map { $0.rank.rawValue }.sorted()
    // Standard straight
    for i in 0..<(ranks.count - 1) {
        if ranks[i+1] != ranks[i] + 1 {
            // Not consecutive
            break
        }
        if i == ranks.count - 2 {
            return true
        }
    }
    // Check Ace-low straight (A-2-3-4-5)
    let aceLowRanks = five.map { $0.rank.rawValue == 14 ? 1 : $0.rank.rawValue }.sorted()
    for i in 0..<(aceLowRanks.count - 1) {
        if aceLowRanks[i+1] != aceLowRanks[i] + 1 {
            return false
        }
    }
    return true
}

func rankCounts(_ five: [Card]) -> [Int: Int] {
    var counts: [Int: Int] = [:]
    for card in five {
        counts[card.rank.rawValue, default: 0] += 1
    }
    return counts
}

// Helper: generate all combinations of k elements from array
private func combinations<T>(from array: [T], choose k: Int) -> [[T]] {
    guard k > 0 else { return [[]] }
    guard let first = array.first else { return [] }
    if array.count < k { return [] }
    
    let head = first
    let subcombosWithHead = combinations(from: Array(array.dropFirst()), choose: k - 1).map { [head] + $0 }
    let subcombosWithoutHead = combinations(from: Array(array.dropFirst()), choose: k)
    
    return subcombosWithHead + subcombosWithoutHead
}
