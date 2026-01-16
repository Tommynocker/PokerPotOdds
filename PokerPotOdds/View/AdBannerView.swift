import SwiftUI
import GoogleMobileAds

struct AdBannerView: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    init(adUnitID: String, adSize: AdSize = AdSizeBanner) {
        self.adUnitID = adUnitID
        self.adSize = adSize
    }

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No-op; size and unit id are fixed. Reload if view appears again.
    }
    
    func makeCoordinator() -> BannerCoordinator {
        BannerCoordinator(self)
    }
}

final class BannerCoordinator: NSObject, BannerViewDelegate {
    private let parent: AdBannerView

    init(_ parent: AdBannerView) {
        self.parent = parent
    }

    // Implement delegate methods as needed; leaving empty to keep behavior minimal.
}

#if DEBUG
#Preview {
    // Use test ad unit id for preview
    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
        .frame(height: 50)
}
#endif
