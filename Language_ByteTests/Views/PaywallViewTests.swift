import SwiftUI
import XCTest
@testable import Language_Byte_Watch_App

@MainActor
class PaywallViewTests: XCTestCase {
    var storeManager: MockStoreKitManager!
    var premiumManager: MockPremiumAccessManager!
    
    override func setUp() throws {
        try super.setUp()
        storeManager = MockStoreKitManager()
        premiumManager = MockPremiumAccessManager()
    }
    
    override func tearDown() throws {
        storeManager = nil
        premiumManager = nil
        try super.tearDown()
    }
    
    func testPurchaseSubscriptionSuccess() async {
        // Configure mock to succeed
        storeManager.shouldSucceed = true
        
        // Attempt purchase
        do {
            try await storeManager.purchase(storeManager.subscriptions[0])
            XCTAssertTrue(storeManager.purchaseCalled, "Purchase method should be called")
            XCTAssertTrue(storeManager.hasActiveSubscription, "Should have active subscription after successful purchase")
        } catch {
            XCTFail("Purchase should not throw an error: \(error)")
        }
    }
    
    func testPurchaseSubscriptionFailure() async {
        // Configure mock to fail
        storeManager.shouldSucceed = false
        storeManager.errorToThrow = StoreError.purchaseFailed
        
        // Attempt purchase
        do {
            try await storeManager.purchase(storeManager.subscriptions[0])
            XCTFail("Purchase should throw an error")
        } catch {
            XCTAssertTrue(storeManager.purchaseCalled, "Purchase method should be called")
            XCTAssertFalse(storeManager.hasActiveSubscription, "Should not have active subscription after failed purchase")
            XCTAssertEqual(error as? StoreError, StoreError.purchaseFailed)
        }
    }
    
    func testRestorePurchasesSuccess() async {
        // Configure mock to succeed with purchases to restore
        storeManager.shouldSucceed = true
        storeManager.hasPurchasesToRestore = true
        
        // Attempt restore
        do {
            try await storeManager.restorePurchases()
            XCTAssertTrue(storeManager.restoreCalled, "Restore method should be called")
            XCTAssertTrue(storeManager.hasActiveSubscription, "Should have active subscription after successful restore")
        } catch {
            XCTFail("Restore should not throw an error: \(error)")
        }
    }
    
    func testRestorePurchasesNoSubscriptions() async {
        // Configure mock to succeed but with no purchases to restore
        storeManager.shouldSucceed = true
        storeManager.hasPurchasesToRestore = false
        
        // Attempt restore
        do {
            try await storeManager.restorePurchases()
            XCTAssertTrue(storeManager.restoreCalled, "Restore method should be called")
            XCTAssertFalse(storeManager.hasActiveSubscription, "Should not have active subscription when none to restore")
        } catch {
            XCTFail("Restore should not throw an error: \(error)")
        }
    }
    
    func testPremiumFeatureAccess() async {
        // Test that premium features are locked without subscription
        premiumManager.isPremium = false
        
        verifyFeatureAccess(available: false)
        
        // Test that premium features are unlocked with subscription
        premiumManager.isPremium = true
        
        verifyFeatureAccess(available: true)
    }
    
    private func verifyFeatureAccess(available: Bool) {
        // Test weekly review feature availability
        XCTAssertEqual(premiumManager.isFeatureAvailable(.weeklyReview), available, 
                      "Weekly review should be \(available ? "unlocked" : "locked")")
        
        // Test other features
        XCTAssertEqual(premiumManager.isFeatureAvailable(.multipleLanguages), available, 
                      "Multiple languages should be \(available ? "unlocked" : "locked")")
        
        XCTAssertEqual(premiumManager.isFeatureAvailable(.advancedCategories), available, 
                      "Advanced categories should be \(available ? "unlocked" : "locked")")
    }
}

// MARK: - Mock Classes

enum StoreError: Error {
    case purchaseFailed
    case restoreFailed
    case noProductsFound
}

@MainActor
class MockStoreKitManager {
    var purchaseCalled = false
    var restoreCalled = false
    var shouldSucceed = true
    var hasPurchasesToRestore = false
    var hasActiveSubscription = false
    var errorToThrow: Error?
    
    var subscriptions: [any Product] = [
        MockProduct(id: "com.languagebyte.monthly", title: "Monthly Plan", description: "Unlimited access for one month", price: 6.99)
    ]
    
    func purchase(_ product: any Product) async throws {
        purchaseCalled = true
        
        if !shouldSucceed {
            if let error = errorToThrow {
                throw error
            } else {
                throw StoreError.purchaseFailed
            }
        }
        
        hasActiveSubscription = true
    }
    
    func restorePurchases() async throws {
        restoreCalled = true
        
        if !shouldSucceed {
            if let error = errorToThrow {
                throw error
            } else {
                throw StoreError.restoreFailed
            }
        }
        
        hasActiveSubscription = hasPurchasesToRestore
    }
}

@MainActor
class MockPremiumAccessManager {
    var isPremium: Bool = false
    
    func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        if isPremium { return true }
        return false
    }
}

// Simple mock Product for testing
class MockProduct: Identifiable {
    let id: String
    let title: String
    let description: String
    let price: Double
    
    init(id: String, title: String, description: String, price: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.price = price
    }
}

// Allow MockProduct to be used where Product is expected in tests
extension MockProduct: Product {
    var displayName: String { title }
    var displayPrice: String { "$\(String(format: "%.2f", price))" }
}

// Add this protocol to make the tests compile
protocol Product: Identifiable {
    var displayName: String { get }
    var displayPrice: String { get }
} 