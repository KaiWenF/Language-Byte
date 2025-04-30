import Foundation

struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let unlocked: Bool
    let iconName: String  // SF Symbol name for the achievement
}

struct AchievementManager {
    static func unlockedAchievements(correctAnswers: Int, bestStreak: Int) -> [Achievement] {
        let totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        let accuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) : 0
        
        return [
            // Beginner achievements
            Achievement(id: "starter", title: "Quiz Novice", description: "Answered 10 questions", 
                unlocked: correctAnswers >= 10, iconName: "1.circle"),
            Achievement(id: "beginner", title: "Language Apprentice", description: "Answered 25 questions", 
                unlocked: correctAnswers >= 25, iconName: "books.vertical"),
            
            // Streak achievements
            Achievement(id: "hotstreak", title: "On Fire", description: "5 correct answers in a row", 
                unlocked: bestStreak >= 5, iconName: "flame"),
            Achievement(id: "inferno", title: "Unstoppable", description: "10 correct answers in a row", 
                unlocked: bestStreak >= 10, iconName: "flame.fill"),
            
            // Accuracy achievements
            Achievement(id: "accurate", title: "Sharp Mind", description: "80% accuracy with at least 20 attempts", 
                unlocked: accuracy >= 0.8 && totalAttempts >= 20, iconName: "brain"),
            Achievement(id: "brainiac", title: "Brainiac", description: "90% accuracy over 50 questions", 
                unlocked: accuracy >= 0.9 && totalAttempts >= 50, iconName: "graduationcap"),
            Achievement(id: "perfect", title: "Perfect Recall", description: "100% accuracy with at least 15 attempts", 
                unlocked: correctAnswers >= 15 && correctAnswers == totalAttempts, iconName: "checkmark.seal.fill"),
            
            // Mastery achievements
            Achievement(id: "dedicated", title: "Dedicated Scholar", description: "Completed 100 quiz questions", 
                unlocked: totalAttempts >= 100, iconName: "books.vertical.fill"),
            Achievement(id: "master", title: "Language Master", description: "Answered 250 questions with 85%+ accuracy", 
                unlocked: totalAttempts >= 250 && Double(correctAnswers) / Double(totalAttempts) >= 0.85, iconName: "crown.fill"),
            
            // Special achievements
            Achievement(id: "comeback", title: "Comeback Kid", description: "Get a question right after 3 wrong answers", 
                unlocked: UserDefaults.standard.bool(forKey: "quiz_comeback"), iconName: "arrow.up.heart"),
            Achievement(id: "speedster", title: "Quick Thinker", description: "Answer 10 questions in under 2 minutes", 
                unlocked: UserDefaults.standard.bool(forKey: "quiz_speedster"), iconName: "bolt.fill")
        ]
    }
} 