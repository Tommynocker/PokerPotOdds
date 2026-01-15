import Foundation
import SwiftUI

// MARK: - Strategy Protocol
protocol SimulationStrategy {
    var id: String { get }
    var displayName: String { get }
    func simulate(hero: [Card?], board: [Card?], activeOpponents: Int, iterations: Int) async -> SimulationResult
}

// MARK: - Concrete Strategies
struct MonteCarloStrategy: SimulationStrategy {
    let id: String = "monteCarlo"
    let displayName: String = "Monte Carlo"

    func simulate(hero: [Card?], board: [Card?], activeOpponents: Int, iterations: Int) async -> SimulationResult {
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let simulator = PokerSimulator()
        return await simulator.simulate(hero: hero, board: board, activeOpponents: activeOpponents, iterations: iterations, rng: &rng)
    }
}

struct HeuristicStrategy: SimulationStrategy {
    let id: String = "heuristic"
    let displayName: String = "Heuristik"

    func simulate(hero: [Card?], board: [Card?], activeOpponents: Int, iterations: Int) async -> SimulationResult {
        // Very rough heuristic: estimate probabilities by sampling fewer iterations and smoothing
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        let simulator = PokerSimulator()
        let lightIterations = max(1000, iterations / 5)
        return await simulator.simulate(hero: hero, board: board, activeOpponents: activeOpponents, iterations: lightIterations, rng: &rng)
    }
}

// MARK: - Manager
final class SimulationManager: ObservableObject {
    private static let selectedStrategyKey = "selectedSimulationID"

    enum StrategyKind: String, CaseIterable, Identifiable {
        case monteCarlo
        case heuristic
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .monteCarlo: return "Monte Carlo"
            case .heuristic: return "Heuristik"
            }
        }
    }

    @Published var selected: StrategyKind = .monteCarlo {
        didSet {
            UserDefaults.standard.set(selected.rawValue, forKey: SimulationManager.selectedStrategyKey)
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: SimulationManager.selectedStrategyKey),
           let kind = StrategyKind(rawValue: raw) {
            self.selected = kind
        } else {
            self.selected = .monteCarlo
            UserDefaults.standard.set(self.selected.rawValue, forKey: SimulationManager.selectedStrategyKey)
        }
    }

    func strategy() -> SimulationStrategy {
        switch selected {
        case .monteCarlo: return MonteCarloStrategy()
        case .heuristic: return HeuristicStrategy()
        }
    }
}
