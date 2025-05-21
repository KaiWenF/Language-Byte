import SwiftUI

struct PremiumFeatureModifier: ViewModifier {
    let feature: PremiumFeature
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    func body(content: Content) -> some View {
        Group {
            if premiumManager.isFeatureAvailable(feature) {
                content
            } else {
                content
                    .overlay(
                        VStack {
                            Image(systemName: "lock.fill")
                                .font(.title)
                                .foregroundColor(.secondary)
                            
                            Text("Premium Feature")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .background(Color.black.opacity(0.1))
                        .onTapGesture {
                            showPaywall = true
                        }
                    )
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: feature)
        }
    }
}

extension View {
    func premiumFeature(_ feature: PremiumFeature) -> some View {
        modifier(PremiumFeatureModifier(feature: feature))
    }
} 