import Foundation

enum AdConfig {
    // Real Ad Unit IDs
    static let bannerAdUnitID: String = "ca-app-pub-8059634022713259/6047134562"
    static let interstitialAdUnitID: String = "ca-app-pub-8059634022713259/6777762306"
    static let rewardedAdUnitID: String = "ca-app-pub-3940256099942544/1712485313"

    // Test Ad Unit IDs (from Google)
    static let testBannerAdUnitID: String = "ca-app-pub-3940256099942544/2934735716"
    static let testInterstitialAdUnitID: String = "ca-app-pub-3940256099942544/4411468910"
    static let testRewardedAdUnitID: String = "ca-app-pub-3940256099942544/1712485313"

    // Convenience accessors: use test IDs in Debug, real in Release
    static var currentBannerID: String {
        #if DEBUG
        return testBannerAdUnitID
        #else
        return bannerAdUnitID
        #endif
    }

    static var currentInterstitialID: String {
        #if DEBUG
        return testInterstitialAdUnitID
        #else
        return interstitialAdUnitID
        #endif
    }

    static var currentRewardedID: String {
        #if DEBUG
        return testRewardedAdUnitID
        #else
        return rewardedAdUnitID
        #endif
    }
}
