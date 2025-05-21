import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @StateObject private var storeManager = StoreKitManager()
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Upgrade to Premium")
                    .font(.title2)
                    .bold()
                
                Text("Unlock all premium features")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Subscription Options
                ForEach(storeManager.subscriptions, id: \.id) { product in
                    SubscriptionProductView(product: product) {
                        await purchase(product)
                    }
                }
                
                // Restore Purchases
                Button("Restore Purchases") {
                    Task {
                        await restorePurchases()
                    }
                }
                .buttonStyle(.bordered)
                
                // Terms and Privacy
                Text("By subscribing, you agree to our Terms of Service and Privacy Policy")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
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
    
    private func purchase(_ product: Product) async {
        isLoading = true
        do {
            try await storeManager.purchase(product)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    private func restorePurchases() async {
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

struct SubscriptionProductView: View {
    let product: Product
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            VStack(spacing: 8) {
                Text(product.displayName)
                    .font(.headline)
                
                Text(product.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(product.displayPrice)
                    .font(.title3)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SubscriptionView()
} 