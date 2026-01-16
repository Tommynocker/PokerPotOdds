import SwiftUI
import GoogleMobileAds

@main
struct PokerPotOddsApp: App {
    @StateObject private var simulationManager = SimulationManager()

    init() {
        // Gather consent, then start Google Mobile Ads SDK when allowed.
        GoogleMobileAdsConsentManager.shared.gatherConsent { error in
            if let error = error {
                print("Consent gathering failed: \(error.localizedDescription)")
            }
            // Attempt to start the SDK if consent allows it.
            GoogleMobileAdsConsentManager.shared.startGoogleMobileAdsSDK()
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(simulationManager)
        }
    }
}
