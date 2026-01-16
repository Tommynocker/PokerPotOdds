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

struct ExactOddsStrategy: SimulationStrategy {
    let id: String = "exactOdds"
    let displayName: String = "Exact Odds"

    func simulate(hero: [Card?], board: [Card?], activeOpponents: Int, iterations: Int) async -> SimulationResult {
        // Deterministic enumeration approach (placeholder):
        // We reuse the PokerSimulator but with a very high, fixed iteration count to approximate determinism
        // or plug in a dedicated exact evaluator if available. For now, call simulator with a fixed seed RNG.
        var rng: any RandomNumberGenerator = SeededRandomNumberGenerator(seed: 42)
        let simulator = PokerSimulator()
        // Use higher iterations to reduce variance; ignore `iterations` parameter
        return await simulator.simulate(hero: hero, board: board, activeOpponents: activeOpponents, iterations: max(iterations, 50_000), rng: &rng)
    }
}

// Simple seeded RNG to keep runs stable for Exact Odds placeholder
struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { self.state = seed }
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}

// MARK: - Manager
final class SimulationManager: ObservableObject {
    private static let selectedStrategyKey = "selectedSimulationID"

    enum StrategyKind: String, CaseIterable, Identifiable {
        case monteCarlo
        case heuristic
        case exactOdds
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .monteCarlo: return "Monte Carlo"
            case .heuristic: return "Heuristik"
            case .exactOdds: return "Exact Odds"
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
        case .exactOdds: return ExactOddsStrategy()
        }
    }
}
