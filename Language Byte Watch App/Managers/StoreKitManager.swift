import StoreKit
import SwiftUI

@MainActor
class StoreKitManager: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    
    // MARK: - Constants
    private let subscriptionGroupID = "group1"
    private let monthlySubscriptionID = "com.languagebyte.premium.monthly"
    private let annualSubscriptionID = "com.languagebyte.premium.annual"
    
    // MARK: - Properties
    private var updateListenerTask: Task<Void, Error>?
    
    // MARK: - Initialization
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Check if user has an active subscription
    var hasActiveSubscription: Bool {
        !purchasedSubscriptions.isEmpty
    }
    
    /// Get the current subscription tier
    var currentSubscriptionTier: SubscriptionTier {
        if hasActiveSubscription {
            return .premium
        }
        return .free
    }
    
    /// Purchase a subscription
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Check whether the transaction is verified
            switch verification {
            case .verified(let transaction):
                // Update the user's purchases
                await updateSubscriptionStatus()
                // Finish the transaction
                await transaction.finish()
            case .unverified:
                throw StoreError.failedVerification
            }
        case .userCancelled:
            throw StoreError.userCancelled
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }
    
    /// Restore purchases
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateSubscriptionStatus()
    }
    
    // MARK: - Private Methods
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    private func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [
                monthlySubscriptionID,
                annualSubscriptionID
            ])
            
            subscriptions = storeProducts.sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    private func updateSubscriptionStatus() async {
        var purchasedSubscriptions: [Product] = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try await checkVerified(result)
                
                if let subscription = subscriptions.first(where: { $0.id == transaction.productID }) {
                    purchasedSubscriptions.append(subscription)
                }
            } catch {
                print("Failed to verify transaction")
            }
        }
        
        self.purchasedSubscriptions = purchasedSubscriptions
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) async throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Supporting Types

enum SubscriptionTier {
    case free
    case premium
}

enum StoreError: LocalizedError {
    case failedVerification
    case userCancelled
    case pending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .userCancelled:
            return "Transaction was cancelled"
        case .pending:
            return "Transaction is pending"
        case .unknown:
            return "Unknown error occurred"
        }
    }
} 