import SwiftUI
#if os(watchOS)
import WatchKit
#endif

// MARK: - XP Utility Functions

/// Static utility class for XP management without state or dependencies
public struct XPUtility {
    // MARK: - Constants
    
    /// XP required per level
    public static let xpPerLevel: Int = 100
    
    /// Notification names
    public static let xpUpdatedNotification = Notification.Name("com.languagebyte.xpUpdated")
    public static let levelUpNotification = Notification.Name("com.languagebyte.levelUp")
    
    // MARK: - Core XP Functions
    
    /// Add XP to user's total
    public static func addXP(_ amount: Int) {
        let defaults = UserDefaults.standard
        
        // Get current values
        let currentXP = defaults.integer(forKey: "xp_total")
        let currentLevel = defaults.integer(forKey: "user_level")
        
        // Calculate new values
        let newXP = currentXP + amount
        let newLevel = 1 + (newXP / xpPerLevel)
        
        // Save new values
        defaults.set(newXP, forKey: "xp_total")
        defaults.set(newLevel, forKey: "user_level")
        defaults.synchronize()
        
        // Post notifications
        NotificationCenter.default.post(
            name: xpUpdatedNotification,
            object: nil,
            userInfo: ["amount": amount, "total": newXP]
        )
        
        // Check for level up
        if newLevel > currentLevel {
            #if os(watchOS)
            WKInterfaceDevice.current().play(.success)
            #endif
            
            NotificationCenter.default.post(
                name: levelUpNotification,
                object: nil,
                userInfo: ["newLevel": newLevel]
            )
        }
    }
    
    /// Get current total XP
    public static func getTotalXP() -> Int {
        return UserDefaults.standard.integer(forKey: "xp_total")
    }
    
    /// Get current user level
    public static func getCurrentLevel() -> Int {
        return UserDefaults.standard.integer(forKey: "user_level")
    }
    
    /// Calculate XP needed for next level
    public static func getXPtoNextLevel() -> Int {
        let totalXP = getTotalXP()
        let userLevel = getCurrentLevel()
        let nextLevelThreshold = userLevel * xpPerLevel
        return max(nextLevelThreshold - totalXP, 0)
    }
    
    /// Get progress percentage towards next level (0.0 to 1.0)
    public static func getLevelProgress() -> Double {
        let totalXP = getTotalXP()
        let userLevel = getCurrentLevel()
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = totalXP - currentLevelXP
        return Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    /// Get level title based on current level
    public static func getLevelTitle() -> String {
        let userLevel = getCurrentLevel()
        
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
    
    // MARK: - Achievement XP Awards
    
    /// Award XP for achievements and milestones
    public static func awardAchievementXP(_ type: AchievementType) {
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
    
    /// Achievement types for different milestones
    public enum AchievementType {
        case correctAnswer
        case streak5
        case streak10
        case streak15
        case quizCompletion
    }
    
    // MARK: - Debug Functions
    
    #if DEBUG
    /// Reset XP (for testing)
    public static func resetXP() {
        UserDefaults.standard.set(0, forKey: "xp_total")
        UserDefaults.standard.set(1, forKey: "user_level")
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: xpUpdatedNotification, object: nil)
    }
    #endif
} 