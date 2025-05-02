import SwiftUI
#if os(watchOS)
import WatchKit
#endif

/// A simple static helper class for XP management without dependencies
/// This can be used directly without worrying about imports or references
struct XPHelper {
    /// Constants
    static let xpPerLevel = 100
    
    /// Notification name for XP updates
    static let xpUpdatedNotification = Notification.Name("com.languagebyte.xpUpdated")
    static let levelUpNotification = Notification.Name("com.languagebyte.levelUp")
    
    /// Add XP to user total
    static func addXP(_ amount: Int) {
        let defaults = UserDefaults.standard
        let currentXP = defaults.integer(forKey: "xp_total")
        let currentLevel = defaults.integer(forKey: "user_level")
        let newXP = currentXP + amount
        let newLevel = 1 + (newXP / xpPerLevel)
        
        // Save new values
        defaults.set(newXP, forKey: "xp_total")
        defaults.set(newLevel, forKey: "user_level")
        defaults.synchronize()
        
        // Publish notification that XP was updated
        NotificationCenter.default.post(
            name: xpUpdatedNotification,
            object: nil,
            userInfo: ["amount": amount, "total": newXP]
        )
        
        // Check for level up
        if newLevel > currentLevel {
            print("Leveled up to \(newLevel)!")
            
            // Provide haptic feedback for level-up
            #if os(watchOS)
            WKInterfaceDevice.current().play(.success)
            #endif
            
            // Post level up notification
            NotificationCenter.default.post(
                name: levelUpNotification,
                object: nil,
                userInfo: ["newLevel": newLevel]
            )
        }
    }
    
    /// Get current total XP
    static func getTotalXP() -> Int {
        return UserDefaults.standard.integer(forKey: "xp_total")
    }
    
    /// Get current user level
    static func getCurrentLevel() -> Int {
        return UserDefaults.standard.integer(forKey: "user_level")
    }
    
    /// Calculate XP needed for next level
    static func getXPtoNextLevel() -> Int {
        let totalXP = getTotalXP()
        let userLevel = getCurrentLevel()
        let nextLevelThreshold = userLevel * xpPerLevel
        return max(nextLevelThreshold - totalXP, 0)
    }
    
    /// Get progress percentage towards next level (0.0 to 1.0)
    static func getLevelProgress() -> Double {
        let totalXP = getTotalXP()
        let currentLevelXP = (getCurrentLevel() - 1) * xpPerLevel
        let xpInCurrentLevel = totalXP - currentLevelXP
        return Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    /// Reset XP (for testing)
    static func resetXP() {
        UserDefaults.standard.set(0, forKey: "xp_total")
        UserDefaults.standard.set(1, forKey: "user_level")
        UserDefaults.standard.synchronize()
        
        // Notify that XP was reset
        NotificationCenter.default.post(name: xpUpdatedNotification, object: nil)
    }
    
    /// Award special XP bonuses
    static func awardBonus(type: BonusType) {
        switch type {
        case .correctAnswer:
            addXP(10)
        case .streak5:
            addXP(20)
        case .streak10:
            addXP(30) 
        case .streak15:
            addXP(50)
        case .quizCompletion:
            addXP(100)
        }
    }
    
    /// Bonus types for different achievements
    enum BonusType {
        case correctAnswer
        case streak5
        case streak10
        case streak15
        case quizCompletion
    }
} 