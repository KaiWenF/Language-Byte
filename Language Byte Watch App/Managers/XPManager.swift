import SwiftUI
#if os(watchOS)
import WatchKit
#endif

/// Manages experience points and leveling functionality
class XPManager: ObservableObject {
    // MARK: - Properties
    
    /// Total XP earned by the user
    @AppStorage("xp_total") var xpTotal: Int = 0
    
    /// Current user level, calculated from XP total
    @AppStorage("user_level") var userLevel: Int = 1
    
    /// XP required per level
    let xpPerLevel: Int = 100
    
    /// Notification name for XP updates
    static let xpUpdatedNotification = Notification.Name("com.languagebyte.xpUpdated")
    
    /// Notification name for level-up events
    static let levelUpNotification = Notification.Name("com.languagebyte.levelUp")
    
    // MARK: - XP Management
    
    /// Add XP to the user's total and recalculate level
    /// - Parameter amount: Amount of XP to add
    func addXP(_ amount: Int) {
        // Store current level for comparison
        let oldLevel = userLevel
        
        // Add XP to total
        xpTotal += amount
        
        // Recalculate level (1 + XP/100)
        userLevel = 1 + (xpTotal / xpPerLevel)
        
        // Post notification for XP update
        NotificationCenter.default.post(
            name: XPManager.xpUpdatedNotification,
            object: nil,
            userInfo: ["amount": amount, "total": xpTotal]
        )
        
        // Check for level-up
        if userLevel > oldLevel {
            // Play haptic feedback for level-up on watchOS
            #if os(watchOS)
            WKInterfaceDevice.current().play(.success)
            #endif
            
            // Post level-up notification
            NotificationCenter.default.post(
                name: XPManager.levelUpNotification,
                object: nil,
                userInfo: ["newLevel": userLevel]
            )
        }
    }
    
    /// Calculate XP needed to reach next level
    /// - Returns: Amount of XP needed
    func xpToNextLevel() -> Int {
        let nextLevelThreshold = userLevel * xpPerLevel
        return max(nextLevelThreshold - xpTotal, 0)
    }
    
    /// Get progress percentage towards next level (0.0 to 1.0)
    /// - Returns: Progress as a value between 0.0 and 1.0
    func getLevelProgress() -> Double {
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = xpTotal - currentLevelXP
        return Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    /// Get level title based on current level
    /// - Returns: String title for the current level
    func getLevelTitle() -> String {
        switch userLevel {
        case 1:
            return "Novice Learner"
        case 2:
            return "Word Explorer"
        case 3:
            return "Language Enthusiast"
        case 4:
            return "Vocabulary Builder"
        case 5:
            return "Fluency Seeker"
        case 6...7:
            return "Language Adept"
        case 8...9:
            return "Linguistic Master"
        case 10...14:
            return "Polyglot Virtuoso"
        case 15...19:
            return "Language Sage"
        case _ where userLevel >= 20:
            return "Grand Language Master"
        default:
            return "Language Student"
        }
    }
} 