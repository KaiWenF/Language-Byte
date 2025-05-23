import SwiftUI
import StoreKit

/// View for prompting users to upgrade to premium
public struct PaywallView: View {
    let feature: PremiumFeature
    @Environment(\.dismiss) private var dismiss
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    public init(feature: PremiumFeature) {
        self.feature = feature
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Unlock Premium")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Feature icon
                Image(systemName: feature.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .padding()
                
                // Feature description
                Text(feature.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Price
                Text("$4.99/month")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical)
                
                // Benefits
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(PremiumFeature.allCases, id: \.self) { benefit in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(benefit.description)
                                .font(.subheadline)
                        }
                    }
                }
                .padding()
                
                // Purchase button
                Button(action: {
                    Task {
                        isLoading = true
                        do {
                            try await premiumManager.purchaseSubscription()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Subscribe Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isLoading)
                .padding(.horizontal)
                
                // Error message
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                }
                
                // Restore purchases button
                Button("Restore Purchases") {
                    Task {
                        isLoading = true
                        do {
                            try await premiumManager.restorePurchases()
                            dismiss()
                        } catch {
                            errorMessage = error.localizedDescription
                        }
                        isLoading = false
                    }
                }
                .font(.caption)
                .padding(.top)
                
                // Terms and privacy
                VStack(spacing: 4) {
                    Text("By subscribing, you agree to our")
                        .font(.caption2)
                    HStack(spacing: 4) {
                        Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
                        Text("and")
                        Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    }
                    .font(.caption2)
                }
                .foregroundColor(.secondary)
                .padding(.top)
            }
            .padding(.bottom)
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(feature: PremiumFeature.multipleLanguages)
    }
} 