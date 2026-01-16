//
//  SimulationView.swift
//  PokerPotOdds
//
//  Created by Thomas Rakowski on 15.01.26.
//

import SwiftUI
import GoogleMobileAds
import UIKit


// MARK: - Model

struct Card: Hashable, Identifiable {
    let rank: Rank
    let suit: Suit

    var id: String { "\(rank.rawValue)-\(suit.rawValue)" }

    var short: String { "\(rank.label)\(suit.symbol)" }
}

// MARK: - UI

struct SimulationView: View {
    // Slots
    @State private var hero: [Card?] = [nil, nil]             // 2 hole cards
    @State private var board: [Card?] = [nil, nil, nil, nil, nil] // 5 board cards
    @State private var opponents: Int = 1 // number of opponents (Mitspieler außer dir)

    @State private var currentIndex: Int = 0 // 0..6 -> hero[0], hero[1], board[0..4]
    @State private var manualDeadOuts: Int = 0 // zusätzliche Outs, die raus sind (durch gegnerische Karten etc.)
    @State private var foldedOpponents: Int = 0 // Mitspieler, die bereits ausgestiegen sind
    
    @AppStorage("hapticsEnabled") private var hapticsEnabled: Bool = true
    @AppStorage("prognosisHapticsEnabled") private var prognosisHapticsEnabled: Bool = false

    @State private var showingPokerHandsSheet = false
    
    @State private var simulatedTop: [PrognosisItem] = []
    @State private var isSimulating: Bool = false
    
    @State private var improvementPercent: Double? = nil

    @EnvironmentObject private var simulationManager: SimulationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    headerSection

                    slotSection

                    Divider()

                    cardGridSection
                }
                .padding()
            }
            .navigationTitle("Simulation")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") { resetAll() }
                }
            }
            .sheet(isPresented: $showingPokerHandsSheet) {
                PokerHandsSheet(hero: hero, board: board, opponents: opponents, foldedOpponents: foldedOpponents)
            }
            .onChange(of: hero) { _ in runSelectedPrognosis() }
            .onChange(of: board) { _ in runSelectedPrognosis() }
            .onChange(of: opponents) { _ in runSelectedPrognosis() }
            .onChange(of: foldedOpponents) { _ in runSelectedPrognosis() }
            .onAppear { runSelectedPrognosis() }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Mitspieler")
                    .foregroundStyle(.secondary)
                Spacer()
                Stepper(value: $opponents, in: 1...8) {
                    Text("\(opponents)")
                        .monospacedDigit()
                        .frame(minWidth: 24, alignment: .trailing)
                }
            }
            HStack {
                Text("Aussteiger")
                    .foregroundStyle(.secondary)
                Spacer()
                Stepper(value: $foldedOpponents, in: 0...opponents) {
                    HStack(spacing: 6) {
                        Text("\(foldedOpponents)")
                            .monospacedDigit()
                    }
                }
            }
        }
    }

    // MARK: Slots

    private var slotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Google AdMob Banner spanning the full width above hand and prognosis
            AdBannerView(adUnitID: AdConfig.bannerAdUnitID)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Deine Hand")
                        .font(.headline)

                    HStack(spacing: 12) {
                        slotView(title: "Hand 1", card: hero[0], isSelected: currentIndex == 0) { currentIndex = 0 }
                        slotView(title: "Hand 2", card: hero[1], isSelected: currentIndex == 1) { currentIndex = 1 }
                    }

                    if let cls = classifyHand(hero: hero, opponents: max(1, opponents - foldedOpponents)) {
                        VStack(alignment: .leading, spacing: 6) {
                            // Zeile mit farbiger Klassifizierung
                            Text(cls.rawValue)
                                .font(.subheadline)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(handClassColor(cls).opacity(0.15)))
                                .overlay(Capsule().stroke(handClassColor(cls), lineWidth: 1))
                                .foregroundStyle(handClassColor(cls))

                          
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: cls)
                    }
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 8) {
                    Button {
                        showingPokerHandsSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            HStack(spacing: 6) {
                                Text("Prognose")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .layoutPriority(1)
                                Image(systemName: "arrow.up")
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .opacity(0.7)
                            }
                            Spacer(minLength: 8)
                            Text(simulationManager.selected.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .lineLimit(1)
                    .buttonStyle(.plain)

                    VStack(alignment: .leading, spacing: 0) {
                        if isSimulating {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Berechne…")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                            }
                            .padding(.vertical, 4)
                        } else if !simulatedTop.isEmpty {
                            let nonZeroItems = simulatedTop.filter { $0.percent > 0 }
                            if nonZeroItems.isEmpty {
                                Text("–")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.vertical, 4)
                            } else {
                                ForEach(nonZeroItems) { item in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(item.color)
                                            .frame(width: 12, height: 12)
                                        Text(item.title)
                                            .font(.subheadline)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        Text(String(format: "%.0f%%", item.percent))
                                            .font(.subheadline)
                                            .monospacedDigit()
                                            .foregroundStyle(.primary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            if let imp = improvementPercent, imp > 0 {
                                Divider()
                                    .padding(.vertical, 6)
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.up.right")
                                    Text("Chance")
                                    Spacer()
                                    Text(String(format: "%.0f%%", imp))
                                        .font(.subheadline)
                                        .monospacedDigit()
                                       
                                }.foregroundStyle(.secondary)
                                .padding(.top, 2)
                            }
                        } else {
                            Text("–")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minHeight: 110, alignment: .topLeading)
                }
            }

            Text("Board")
                .font(.headline)
                .padding(.top, 4)

            HStack(spacing: 10) {
                slotView(title: "F1", card: board[0], isSelected: currentIndex == 2) { currentIndex = 2 }
                slotView(title: "F2", card: board[1], isSelected: currentIndex == 3) { currentIndex = 3 }
                slotView(title: "F3", card: board[2], isSelected: currentIndex == 4) { currentIndex = 4 }
                slotView(title: "T",  card: board[3], isSelected: currentIndex == 5) { currentIndex = 5 }
                slotView(title: "R",  card: board[4], isSelected: currentIndex == 6) { currentIndex = 6 }
            }

            // Quick clear actions
            HStack(spacing: 10) {
                Button("Hand löschen") { hero = [nil, nil]; currentIndex = 0 }
                    .buttonStyle(.bordered)

                Button("Board löschen") { board = [nil, nil, nil, nil, nil]; currentIndex = 2 }
                    .buttonStyle(.bordered)

                Spacer()
            }
        }
    }

    private func slotView(title: String, card: Card?, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(card?.short ?? "—")
                    .font(.title3)
                    .monospacedDigit()
                    .foregroundStyle(card?.suit.isRed == true ? .red : .primary)
            }
            .frame(width: 62, height: 74)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .onTapGesture(count: 2) {
            removeCardFromSlot(title: title)
        }
        .contextMenu {
            Button(role: .destructive) {
                removeCardFromSlot(title: title)
            } label: {
                Label("Slot leeren", systemImage: "trash")
            }
        }
    }

    private func removeCardFromSlot(title: String) {
        // Map the visible title to the slot index
        switch title {
        case "Hand 1": hero[0] = nil; currentIndex = 0
        case "Hand 2": hero[1] = nil; currentIndex = 1
        case "F1": board[0] = nil; currentIndex = 2
        case "F2": board[1] = nil; currentIndex = 3
        case "F3": board[2] = nil; currentIndex = 4
        case "T": board[3] = nil; currentIndex = 5
        case "R": board[4] = nil; currentIndex = 6
        default: break
        }
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 1)
        }
    }

    // MARK: Card Grid

    private var cardGridSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Karten auswählen")
                .font(.headline)

            let cols = Array(repeating: GridItem(.flexible(), spacing: 8), count: 8)

            LazyVGrid(columns: cols, spacing: 8) {
                ForEach(allCards(), id: \.self) { card in
                    cardButton(card)
                }
            }
            .padding(.vertical, 6)
        }
    }

    private func cardButton(_ card: Card) -> some View {
        let used = usedCards()
        let isUsed = used.contains(card)

        return Button {
            if !isUsed { handleCardTap(card) }
        } label: {
            Text(card.short)
                .font(.subheadline)
                .monospacedDigit()
                .frame(maxWidth: .infinity, minHeight: 38)
                .foregroundStyle(
                    isUsed
                    ? (card.suit.isRed ? Color.red.opacity(0.5) : Color.secondary)
                    : (card.suit.isRed ? Color.red : Color.primary)
                )
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isUsed ? Color(.tertiarySystemFill) : Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isUsed ? Color(.quaternaryLabel) : Color.clear, lineWidth: 1)
                )
                .opacity(isUsed ? 0.6 : 1.0)
        }
        .disabled(isUsed)
    }

    // MARK: Tap Logic

    private func handleCardTap(_ card: Card) {
        // If already in any slot -> remove it
        if isCardCurrentlyInAnySlot(card) {
            withAnimation(.easeInOut(duration: 0.2)) {
                removeCardEverywhere(card)
            }
            // Haptic feedback on card removal
            if hapticsEnabled {
                let generator = UIImpactFeedbackGenerator(style: .heavy)
                generator.prepare()
                generator.impactOccurred(intensity: 0.7)
            }
            return
        }

        // Place in current slot and advance to next free slot
        withAnimation(.easeInOut(duration: 0.2)) {
            placeInCurrentSlot(card)
            advanceToNextFreeSlot()
        }
        // Subtle haptic feedback when a card is selected (if enabled)
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 1)
        }
    }

    private func placeInCurrentSlot(_ card: Card) {
        switch currentIndex {
        case 0: hero[0] = card
        case 1: hero[1] = card
        case 2: board[0] = card
        case 3: board[1] = card
        case 4: board[2] = card
        case 5: board[3] = card
        case 6: board[4] = card
        default: break
        }
    }

    private func advanceToNextFreeSlot() {
        // define order of slots indices 0..6
        let slots: [Card?] = [hero[0], hero[1], board[0], board[1], board[2], board[3], board[4]]
        // start searching from next index
        var idx = currentIndex + 1
        // wrap around once
        for _ in 0..<slots.count {
            if idx >= slots.count { idx = 0 }
            if (idx == 0 && hero[0] == nil) { currentIndex = 0; return }
            if (idx == 1 && hero[1] == nil) { currentIndex = 1; return }
            if (idx == 2 && board[0] == nil) { currentIndex = 2; return }
            if (idx == 3 && board[1] == nil) { currentIndex = 3; return }
            if (idx == 4 && board[2] == nil) { currentIndex = 4; return }
            if (idx == 5 && board[3] == nil) { currentIndex = 5; return }
            if (idx == 6 && board[4] == nil) { currentIndex = 6; return }
            idx += 1
        }
        // if all filled, keep pointing to last (river)
        currentIndex = 6
    }

    private func placeInNextFreeSlot(_ card: Card) {
        if hero[0] == nil { hero[0] = card; advanceToNextFreeSlot(); return }
        if hero[1] == nil { hero[1] = card; advanceToNextFreeSlot(); return }
        for i in 0..<board.count where board[i] == nil {
            board[i] = card
            advanceToNextFreeSlot()
            return
        }
        // If everything is filled, overwrite the last board card (simple behavior)
        board[4] = card
        advanceToNextFreeSlot()
    }

    private func removeCardEverywhere(_ card: Card) {
        if hero[0] == card { hero[0] = nil }
        if hero[1] == card { hero[1] = nil }
        for i in 0..<board.count where board[i] == card {
            board[i] = nil
        }
        if hapticsEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 1)
        }
        advanceToNextFreeSlot()
    }

    private func isCardCurrentlyInAnySlot(_ card: Card) -> Bool {
        hero.contains(card) || board.contains(card)
    }

    private func usedCards() -> Set<Card> {
        var s = Set<Card>()
        for c in hero.compactMap({ $0 }) { s.insert(c) }
        for c in board.compactMap({ $0 }) { s.insert(c) }
        return s
    }

    private func allCards() -> [Card] {
        var cards: [Card] = []
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                cards.append(Card(rank: rank, suit: suit))
            }
        }
        // Optional: Sort by rank then suit for nicer grid
        cards.sort { (a, b) in
            if a.rank.rawValue != b.rank.rawValue { return a.rank.rawValue > b.rank.rawValue }
            return a.suit.rawValue < b.suit.rawValue
        }
        return cards
    }
    
    private func pokerHandColorLookup() -> [String: Color] {
        Dictionary(uniqueKeysWithValues: allPokerHands.map { ($0.title, $0.color) })
    }

    private func colorForHandTitle(_ title: String) -> Color {
        pokerHandColorLookup()[title] ?? .primary
    }

    private struct PrognosisItem: Identifiable {
        let id = UUID()
        let title: String
        let percent: Double
        let color: Color
    }

    private func topThreePrognosis(hero: [Card?], board: [Card?]) -> [PrognosisItem]? {
        let heroCards = hero.compactMap { $0 }
        guard heroCards.count >= 2 else { return nil }
        
        let items = allPokerHands.map { hand in
            let pct = pokerHandProbability(for: hand.title, hero: hero, board: board, opponents: max(1, opponents - foldedOpponents), foldedOpponents: foldedOpponents)
            return PrognosisItem(title: hand.title, percent: pct, color: colorForHandTitle(hand.title))
        }
        
        let top = items.sorted { $0.percent > $1.percent }.prefix(4)
        return Array(top)
    }
    
    private func runSelectedPrognosis() {
        let heroCards = hero.compactMap { $0 }
        guard heroCards.count == 2 else { simulatedTop = []; improvementPercent = nil; isSimulating = false; return }
        let boardCards = board.compactMap { $0 }
        let activeOpponents = max(1, opponents - foldedOpponents)
        let iterations: Int
        switch boardCards.count {
        case 0: iterations = 10000
        case 1...3: iterations = 8000
        case 4: iterations = 6000
        default: iterations = 4000
        }
        isSimulating = true
        simulatedTop = []

        // Capture strategy on the main actor to avoid sending a non-Sendable existential into the Task
        let strategy = simulationManager.strategy()

        Task {
            let result = await strategy.simulate(hero: hero, board: board, activeOpponents: activeOpponents, iterations: iterations)
            await MainActor.run {
                let total = max(1, result.iterations)
                let mapping: Array<(HandCategory, String)> = [
                    (.royalFlush, "Royal Flush"),
                    (.straightFlush, "Straight Flush"),
                    (.fourOfAKind, "Vierling"),
                    (.fullHouse, "Full House"),
                    (.flush, "Flush"),
                    (.straight, "Straight"),
                    (.threeOfAKind, "Drilling"),
                    (.twoPair, "Zwei Paare"),
                    (.onePair, "Ein Paar"),
                    (.highCard, "Hohe Karte")
                ]
                var items: [PrognosisItem] = []
                for (cat, title) in mapping {
                    let count = result.handCategoryCounts[cat] ?? 0
                    let pct = 100.0 * Double(count) / Double(total)
                    let color = colorForHandTitle(title)
                    items.append(PrognosisItem(title: title, percent: pct, color: color))
                }
                let havePairNow = currentlyAtLeastPair(hero: hero, board: board)
                let knownBoardCount = board.compactMap { $0 }.count
                if knownBoardCount == 5 {
                    improvementPercent = 0
                } else {
                    let percentByTitle: [String: Double] = Dictionary(uniqueKeysWithValues: items.map { ($0.title, $0.percent) })
                    func pct(_ title: String) -> Double { percentByTitle[title] ?? 0 }
                    let betterThanPairTitles = [
                        "Zwei Paare", "Drilling", "Straight", "Flush", "Full House", "Vierling", "Straight Flush", "Royal Flush"
                    ]
                    let atLeastPairTitles = [
                        "Ein Paar", "Zwei Paare", "Drilling", "Straight", "Flush", "Full House", "Vierling", "Straight Flush", "Royal Flush"
                    ]
                    let improvement = (havePairNow ? betterThanPairTitles : atLeastPairTitles).reduce(0.0) { $0 + pct($1) }
                    improvementPercent = improvement
                }

                simulatedTop = Array(items.filter { $0.percent > 0 }.sorted { $0.percent > $1.percent }.prefix(4))
                isSimulating = false

                if prognosisHapticsEnabled && hapticsEnabled {
                    let generator = UINotificationFeedbackGenerator()
                    generator.prepare()
                    generator.notificationOccurred(.success)
                }
            }
        }
    }
    
    private func continueProbability(hero: [Card?], opponents: Int, board: [Card?]) -> Double? {
        guard let c1 = hero[0], let c2 = hero[1] else { return nil }
        // Very rough preflop-ish heuristic:
        // Start with base score
        var score: Double = 0
        // Pair bonus
        if c1.rank == c2.rank { score += 35 }
        // High-card bonus
        let highRanks: Set<Rank> = [.ace, .king, .queen, .jack, .ten]
        if highRanks.contains(c1.rank) { score += 10 }
        if highRanks.contains(c2.rank) { score += 10 }
        // Suited bonus
        if c1.suit == c2.suit { score += 8 }
        // Connectivity bonus (for connectors and one-gappers)
        let gap = abs(c1.rank.rawValue - c2.rank.rawValue)
        if gap == 1 { score += 6 } else if gap == 2 { score += 3 }

        // Slightly scale down with more opponents
        let oppFactor = max(1, min(8, opponents))
        var adjusted = max(0, min(100, score * (1.0 - 0.05 * Double(oppFactor - 1))))

        // Adjust by available outs vs baseline (if many outs are dead, reduce slightly)
        if let outs = availableOuts(hero: hero, board: board) {
            if outs.baseline > 0 {
                let ratio = Double(outs.available) / Double(outs.baseline)
                adjusted = adjusted * (0.8 + 0.2 * ratio)
            }
        }

        // If there's a board, nudge up a bit if we already have a pair with board ranks
        if board.compactMap({ $0 }).contains(where: { $0.rank == c1.rank || $0.rank == c2.rank }) {
            adjusted = min(100, adjusted + 5)
        }
        return max(0, min(100, adjusted))
    }

    private func streetTitle(for board: [Card?]) -> String {
        let count = board.compactMap { $0 }.count
        switch count {
        case 0: return "Preflop"
        case 1...3: return "Flop"
        case 4: return "Turn"
        case 5: return "River"
        default: return "Preflop"
        }
    }
    
    private func currentlyAtLeastPair(hero: [Card?], board: [Card?]) -> Bool {
        let known = hero.compactMap { $0 } + board.compactMap { $0 }
        let ranks = Dictionary(grouping: known, by: { $0.rank })
        return ranks.values.contains(where: { $0.count >= 2 })
    }
    
    private enum HandClass: String {
        case premium = "Premium"
        case strong = "Stark"
        case playable = "Spielbar"
        case weak = "Schwach"
    }

    private func classifyHand(hero: [Card?], opponents: Int) -> HandClass? {
        guard let c1 = hero[0], let c2 = hero[1] else { return nil }
        let r1 = c1.rank.rawValue
        let r2 = c2.rank.rawValue
        let highRanks: Set<Rank> = [.ace, .king, .queen, .jack, .ten]
        let suited = c1.suit == c2.suit
        let pair = c1.rank == c2.rank
        let maxR = max(r1, r2)
        let minR = min(r1, r2)
        let gap = abs(r1 - r2)

        // Base classification
        var base: HandClass
        // Premium: AA, KK, QQ, AKs
        if pair && (c1.rank == .ace || c1.rank == .king || c1.rank == .queen) {
            base = .premium
        } else if suited && ((c1.rank == .ace && c2.rank == .king) || (c1.rank == .king && c2.rank == .ace)) {
            base = .premium
        }
        // Strong: JJ, TT, AQs, AJs, KQs, AK (offsuit)
        else if pair && (c1.rank == .jack || c1.rank == .ten) {
            base = .strong
        } else if suited && ((highRanks.contains(c1.rank) && highRanks.contains(c2.rank)) && (maxR >= Rank.queen.rawValue)) {
            base = .strong
        } else if ( (c1.rank == .ace && c2.rank == .king) || (c1.rank == .king && c2.rank == .ace) ) {
            base = .strong
        }
        // Playable: mittlere Paare 99–66, suited connectors/gapper (JTs, T9s, 98s, QJs), Ax suited
        else if pair && (minR >= Rank.six.rawValue && maxR <= Rank.nine.rawValue) {
            base = .playable
        } else if suited && (gap <= 2) && (highRanks.contains(c1.rank) || highRanks.contains(c2.rank) || maxR >= Rank.nine.rawValue) {
            base = .playable
        } else if suited && (c1.rank == .ace || c2.rank == .ace) {
            base = .playable
        }
        // Alles andere: schwach
        else {
            base = .weak
        }

        // Adjust for opponents: more opponents -> more conservative; very few -> slightly looser
        let opp = max(1, min(8, opponents))
        func shift(_ cls: HandClass, by delta: Int) -> HandClass {
            let order: [HandClass] = [.weak, .playable, .strong, .premium]
            guard let idx = order.firstIndex(of: cls) else { return cls }
            let newIdx = max(0, min(order.count - 1, idx + delta))
            return order[newIdx]
        }

        var adjusted = base
        if opp >= 6 {
            adjusted = shift(base, by: -1)
        } else if opp <= 2 {
            adjusted = shift(base, by: +1)
        }
        return adjusted
    }

    private func handClassColor(_ cls: HandClass) -> Color {
        switch cls {
        case .premium: return .green
        case .strong: return .blue
        case .playable: return .orange
        case .weak: return .red
        }
    }
    
    private func allUsedCards() -> Set<Card> {
        var s = Set<Card>()
        for c in hero.compactMap({ $0 }) { s.insert(c) }
        for c in board.compactMap({ $0 }) { s.insert(c) }
        return s
    }

    // Very rough outs model: next-card improvement outs
    private func estimateBaselineOutsForNextCard(hero: [Card?], board: [Card?]) -> Int? {
        guard let c1 = hero[0], let c2 = hero[1] else { return nil }
        let boardCount = board.compactMap { $0 }.count
        // Preflop/Flop/Turn: consider next-card improvement
        // If unpaired hand: 6 outs to pair (3 of each rank)
        if c1.rank != c2.rank {
            return 6
        } else {
            // Pocket pair: 2 outs to set on next card (2 remaining of that rank)
            return 2
        }
    }

    private func availableOuts(hero: [Card?], board: [Card?]) -> (baseline: Int, available: Int, dead: Int)? {
        guard let c1 = hero[0], let c2 = hero[1] else { return nil }
        guard let baseline = estimateBaselineOutsForNextCard(hero: hero, board: board) else { return nil }
        let used = allUsedCards()

        var outsCards = Set<Card>()
        if c1.rank != c2.rank {
            // 3 of each rank (other suits) for pairing either card
            for s in Suit.allCases {
                let card1 = Card(rank: c1.rank, suit: s)
                let card2 = Card(rank: c2.rank, suit: s)
                outsCards.insert(card1)
                outsCards.insert(card2)
            }
            // remove the two hero cards themselves
            outsCards.remove(c1)
            outsCards.remove(c2)
        } else {
            // Pocket pair: 2 remaining of that rank (all suits minus the two we hold)
            for s in Suit.allCases {
                let card = Card(rank: c1.rank, suit: s)
                outsCards.insert(card)
            }
            outsCards.remove(c1)
            outsCards.remove(c2)
        }

        // Only next-card outs count; some may already be visible on board/hand (dead)
        let autoDead = outsCards.filter { used.contains($0) }.count
        let totalDead = autoDead + max(0, manualDeadOuts)
        let available = max(0, baseline - totalDead)
        return (baseline, available, totalDead)
    }
    
    private func resetAll() {
        withAnimation(.easeInOut(duration: 0.2)) {
            hero = [nil, nil]
            board = [nil, nil, nil, nil, nil]
            opponents = 1
            foldedOpponents = 0
            currentIndex = 0
            manualDeadOuts = 0
        }
    }
}

private struct ShimmerView: View {
    @State private var phase: CGFloat = -1

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(.systemFill).opacity(0.3),
                Color.white.opacity(0.6),
                Color(.systemFill).opacity(0.3)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
        .mask(
            Rectangle()
                .fill(Color.white)
        )
        .modifier(ShimmerAnimation(phase: phase))
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 2
            }
        }
    }
}

private struct ShimmerAnimation: ViewModifier {
    let phase: CGFloat
    func body(content: Content) -> some View {
        content
            .offset(x: UIScreen.main.bounds.width * phase)
    }
}

// MARK: - Preview

#Preview {
    SimulationView()
        .environmentObject(SimulationManager())
    
}

