import Foundation
import SwiftUI

struct AchievementManager {
    // Define local achievement result
    struct AchievementResult: Identifiable {
        let id: String
        let title: String
        let description: String
        let unlocked: Bool
        let iconName: String
    }
    
    static func unlockedAchievements(correctAnswers: Int, bestStreak: Int) -> [AchievementResult] {
        let totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        let accuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) : 0
        let totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        let userLevel = UserDefaults.standard.integer(forKey: "user_level")
        
        return [
            // Beginner achievements
            AchievementResult(id: "starter", title: "Quiz Novice", description: "Answered 10 questions", 
                unlocked: correctAnswers >= 10, iconName: "1.circle"),
            AchievementResult(id: "beginner", title: "Language Apprentice", description: "Answered 25 questions", 
                unlocked: correctAnswers >= 25, iconName: "books.vertical"),
            
            // Streak achievements
            AchievementResult(id: "hotstreak", title: "On Fire", description: "5 correct answers in a row", 
                unlocked: bestStreak >= 5, iconName: "flame"),
            AchievementResult(id: "inferno", title: "Unstoppable", description: "10 correct answers in a row", 
                unlocked: bestStreak >= 10, iconName: "flame.fill"),
            
            // Accuracy achievements
            AchievementResult(id: "accurate", title: "Sharp Mind", description: "80% accuracy with at least 20 attempts", 
                unlocked: accuracy >= 0.8 && totalAttempts >= 20, iconName: "brain"),
            AchievementResult(id: "brainiac", title: "Brainiac", description: "90% accuracy over 50 questions", 
                unlocked: accuracy >= 0.9 && totalAttempts >= 50, iconName: "graduationcap"),
            AchievementResult(id: "perfect", title: "Perfect Recall", description: "100% accuracy with at least 15 attempts", 
                unlocked: correctAnswers >= 15 && correctAnswers == totalAttempts, iconName: "checkmark.seal.fill"),
            
            // Mastery achievements
            AchievementResult(id: "dedicated", title: "Dedicated Scholar", description: "Completed 100 quiz questions", 
                unlocked: totalAttempts >= 100, iconName: "books.vertical.fill"),
            AchievementResult(id: "master", title: "Language Master", description: "Answered 250 questions with 85%+ accuracy", 
                unlocked: totalAttempts >= 250 && Double(correctAnswers) / Double(totalAttempts) >= 0.85, iconName: "crown.fill"),
            
            // Special achievements
            AchievementResult(id: "comeback", title: "Comeback Kid", description: "Get a question right after 3 wrong answers", 
                unlocked: UserDefaults.standard.bool(forKey: "quiz_comeback"), iconName: "arrow.up.heart"),
            AchievementResult(id: "speedster", title: "Quick Thinker", description: "Answer 10 questions in under 2 minutes", 
                unlocked: UserDefaults.standard.bool(forKey: "quiz_speedster"), iconName: "bolt.fill"),
            
            // XP-based achievements
            AchievementResult(id: "level_5", title: "Level 5 Reached", description: "Earn 500 XP total", 
                unlocked: userLevel >= 5 || totalXP >= 500, iconName: "star.fill"),
            AchievementResult(id: "level_10", title: "Dedicated Learner", description: "Earn 1,000 XP total", 
                unlocked: userLevel >= 10 || totalXP >= 1000, iconName: "flame.fill"),
            AchievementResult(id: "xp_milestone_100", title: "First Steps", description: "Earn your first 100 XP", 
                unlocked: totalXP >= 100, iconName: "figure.walk"),
            AchievementResult(id: "xp_milestone_2500", title: "XP Champion", description: "Accumulate 2,500 XP", 
                unlocked: totalXP >= 2500, iconName: "trophy.fill"),
            AchievementResult(id: "word_master", title: "Word Master", description: "Reach level 15", 
                unlocked: userLevel >= 15, iconName: "crown.fill")
        ]
    }
} 