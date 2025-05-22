import SwiftUI
import StoreKit

/// View for prompting users to upgrade to premium
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreKitManager()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    let feature: PremiumFeature
    
    @State private var selectedPlan: SubscriptionPlan = .monthly
    
    enum SubscriptionPlan {
        case monthly
        case annual
        
        var price: String {
            switch self {
            case .monthly: return "$6.99"
            case .annual: return "$49.99"
            }
        }
        
        var period: String {
            switch self {
            case .monthly: return "month"
            case .annual: return "year"
            }
        }
        
        var discount: String? {
            switch self {
            case .monthly: return nil
            case .annual: return "Save 40%"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.yellow)
                
                Text("Language Byte Premium")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                // Feature description
                Text(getFeatureDescription())
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Feature list
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "sparkles", text: "Advanced word bundles tailored for your level")
                    FeatureRow(icon: "chart.bar.fill", text: "Weekly progress reviews")
                    FeatureRow(icon: "gauge.high", text: "Enhanced quiz features")
                    FeatureRow(icon: "trophy.fill", text: "Achievement tracking")
                    FeatureRow(icon: "speaker.wave.2.fill", text: "Voice customization")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // Subscription options
                VStack(spacing: 12) {
                    // Monthly option
                    SubscriptionOptionView(
                        plan: .monthly,
                        isSelected: selectedPlan == .monthly,
                        action: { selectedPlan = .monthly }
                    )
                    
                    // Annual option
                    SubscriptionOptionView(
                        plan: .annual,
                        isSelected: selectedPlan == .annual,
                        action: { selectedPlan = .annual }
                    )
                }
                
                // Subscribe button
                Button(action: { Task { await subscribeAction() } }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Subscribe Now")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                
                // Restore purchases button
                Button("Restore Purchases") {
                    Task { await restorePurchasesAction() }
                }
                .font(.caption)
                .padding(.top, 8)
                
                // Terms and privacy notes
                Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                
                // Dismiss button
                Button("No Thanks") {
                    dismiss()
                }
                .padding()
            }
            .padding()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // Helper to get feature-specific description
    private func getFeatureDescription() -> String {
        switch feature {
        case .aiWordBundles:
            return "Unlock AI-powered word bundles tailored to your learning style and level"
        case .weeklyReview:
            return "Access detailed weekly reviews of your learning progress"
        case .quizEnhancements:
            return "Unlock enhanced quiz features with personalized difficulty levels"
        case .achievements:
            return "Track your achievements and progress throughout your language learning journey"
        case .levelUpAnimations:
            return "Enjoy special level-up animations to celebrate your progress"
        case .voiceCustomization:
            return "Customize voice settings for a personalized learning experience"
        case .multipleLanguages:
            return "Unlock all language pairs and learn multiple languages simultaneously"
        case .advancedCategories:
            return "Access all word categories including Phrases, Emotions, and Food"
        case .xpBoost:
            return "Get 2x XP on special days and level up faster"
        }
    }
    
    // Subscription action
    private func subscribeAction() async {
        isLoading = true
        do {
            let product = storeManager.subscriptions.first { product in
                switch selectedPlan {
                case .monthly:
                    return product.id == "com.languagebyte.premium.monthly"
                case .annual:
                    return product.id == "com.languagebyte.premium.annual"
                }
            }
            
            guard let product = product else {
                throw StoreError.unknown
            }
            
            try await storeManager.purchase(product)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    // Restore purchases action
    private func restorePurchasesAction() async {
        isLoading = true
        do {
            try await storeManager.restorePurchases()
            if storeManager.hasActiveSubscription {
                dismiss()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}

// Helper view for subscription options
struct SubscriptionOptionView: View {
    let plan: PaywallView.SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading) {
                    Text(plan == .monthly ? "Monthly" : "Annual")
                        .font(.headline)
                    
                    Text("\(plan.price)/\(plan.period)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if let discount = plan.discount {
                    Text(discount)
                        .font(.caption)
                        .padding(4)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Helper view for feature rows
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.subheadline)
            
            Spacer()
        }
    }
}

struct PremiumFeatureView: View {
    let feature: PremiumFeature
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(feature) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: feature)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        // This will be overridden by the parent view
        EmptyView()
    }
    
    private var lockedContent: some View {
        VStack {
            Image(systemName: "lock.fill")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("Premium Feature")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .onTapGesture {
            showPaywall = true
        }
    }
}

#Preview {
    PaywallView(feature: .achievements)
} 