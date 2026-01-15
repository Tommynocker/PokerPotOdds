import SwiftUI

@main
struct PokerPotOddsApp: App {
    @StateObject private var simulationManager = SimulationManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(simulationManager)
        }
    }
}
