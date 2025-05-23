import SwiftUI
import StoreKit

// MARK: - Premium Feature Types
public enum PremiumFeature: String, CaseIterable, Hashable {
    case multipleLanguages
    case advancedCategories
    case quizEnhancements
    case weeklyReview
    case voiceCustomization
    case aiWordBundles
    case achievements
    case levelUpAnimations
    
    public var description: String {
        switch self {
        case .multipleLanguages:
            return "Learn multiple languages simultaneously"
        case .advancedCategories:
            return "Access advanced word categories and specialized vocabulary"
        case .quizEnhancements:
            return "Enhanced quiz features with personalized difficulty"
        case .weeklyReview:
            return "Weekly progress reviews and insights"
        case .voiceCustomization:
            return "Customize voice settings for a personalized learning experience"
        case .aiWordBundles:
            return "AI-powered word recommendations and personalized learning paths"
        case .achievements:
            return "Track your progress with achievements and milestones"
        case .levelUpAnimations:
            return "Celebrate your progress with engaging level-up animations"
        }
    }
    
    public var icon: String {
        switch self {
        case .multipleLanguages:
            return "globe"
        case .advancedCategories:
            return "folder.fill"
        case .quizEnhancements:
            return "star.fill"
        case .weeklyReview:
            return "chart.bar.fill"
        case .voiceCustomization:
            return "waveform"
        case .aiWordBundles:
            return "brain"
        case .achievements:
            return "trophy.fill"
        case .levelUpAnimations:
            return "sparkles"
        }
    }
}

// MARK: - Premium Access Manager
@MainActor
public class PremiumAccessManager: ObservableObject {
    // MARK: - Singleton
    public static let shared = PremiumAccessManager()
    
    // MARK: - Published Properties
    @Published public private(set) var isPremium: Bool = false
    @Published public private(set) var hasActiveTrial: Bool = false
    @Published public private(set) var trialEndDate: Date?
    @Published public private(set) var lastUpgradePrompt: Date?
    @Published public private(set) var upgradePromptCount: Int = 0
    
    // MARK: - Constants
    private let maxUpgradePrompts = 3
    private let upgradePromptInterval: TimeInterval = 24 * 60 * 60 // 24 hours
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    // MARK: - User Activity Tracking
    @AppStorage("days_of_use") private var daysOfUse: Int = 0
    @AppStorage("words_viewed") private var wordsViewed: Int = 0
    @AppStorage("quizzes_completed") private var quizzesCompleted: Int = 0
    @AppStorage("first_launch_date") private var firstLaunchDate: Date = Date()
    
    // MARK: - Initialization
    private init() {
        Task {
            await checkSubscriptionStatus()
            await checkTrialStatus()
        }
    }
    
    // MARK: - Public Methods
    
    /// Check if a feature is available to the user
    public func isFeatureAvailable(_ feature: PremiumFeature) -> Bool {
        if isPremium { return true }
        return false // All features require premium
    }
    
    /// Track user activity and potentially trigger upgrade prompts
    public func trackActivity(_ activity: UserActivity) {
        switch activity {
        case .wordViewed:
            wordsViewed += 1
            if wordsViewed == 10 {
                showUpgradePromptIfNeeded()
            }
        case .quizCompleted:
            quizzesCompleted += 1
            if quizzesCompleted == 1 {
                showUpgradePromptIfNeeded()
            }
        case .appLaunched:
            let calendar = Calendar.current
            if let days = calendar.dateComponents([.day], from: firstLaunchDate, to: Date()).day {
                daysOfUse = days
                if days == 5 {
                    showUpgradePromptIfNeeded()
                }
            }
        }
    }
    
    /// Start a free trial
    public func startTrial() async throws {
        guard !hasActiveTrial else { return }
        
        trialEndDate = Date().addingTimeInterval(trialDuration)
        hasActiveTrial = true
        isPremium = true
        
        // Save trial status
        UserDefaults.standard.set(trialEndDate, forKey: "trial_end_date")
        UserDefaults.standard.set(true, forKey: "has_active_trial")
    }
    
    /// Purchase a subscription
    public func purchaseSubscription() async throws {
        // This will be implemented with StoreKit integration
        // For now, we'll use a mock implementation
        isPremium = true
        UserDefaults.standard.set(true, forKey: "is_premium")
    }
    
    /// Restore purchases
    public func restorePurchases() async throws {
        // This will be implemented with StoreKit integration
        // For now, we'll use a mock implementation
        isPremium = UserDefaults.standard.bool(forKey: "is_premium")
    }
    
    /// Check if user should see an upgrade prompt
    public func shouldShowUpgradePrompt() -> Bool {
        guard !isPremium else { return false }
        guard upgradePromptCount < maxUpgradePrompts else { return false }
        
        if let lastPrompt = lastUpgradePrompt {
            let timeSinceLastPrompt = Date().timeIntervalSince(lastPrompt)
            return timeSinceLastPrompt >= upgradePromptInterval
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func showUpgradePromptIfNeeded() {
        guard shouldShowUpgradePrompt() else { return }
        
        lastUpgradePrompt = Date()
        upgradePromptCount += 1
        
        // Post notification for views to show upgrade prompt
        NotificationCenter.default.post(name: .showUpgradePrompt, object: nil)
    }
    
    private func checkSubscriptionStatus() async {
        // This will be implemented with StoreKit integration
        // For now, we'll use a mock implementation
        isPremium = UserDefaults.standard.bool(forKey: "is_premium")
    }
    
    private func checkTrialStatus() async {
        hasActiveTrial = UserDefaults.standard.bool(forKey: "has_active_trial")
        if let endDate = UserDefaults.standard.object(forKey: "trial_end_date") as? Date {
            trialEndDate = endDate
            if Date() > endDate {
                hasActiveTrial = false
                isPremium = false
                UserDefaults.standard.set(false, forKey: "has_active_trial")
            }
        }
    }
}

// MARK: - Supporting Types

public enum UserActivity {
    case wordViewed
    case quizCompleted
    case appLaunched
}

extension Notification.Name {
    public static let showUpgradePrompt = Notification.Name("showUpgradePrompt")
} 