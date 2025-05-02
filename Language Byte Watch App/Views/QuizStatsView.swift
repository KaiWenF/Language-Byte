import SwiftUI
import Foundation

// Local achievement struct that matches the one from AchievementManager
fileprivate struct QuizAchievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
}

struct QuizStatsView: View {
    // Use State variables instead of AppStorage to ensure refreshing
    @State private var totalAttempts: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var bestStreak: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 Quiz Stats")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)

                if totalAttempts > 0 {
                    Group {
                        HStack {
                            Text("Questions Attempted:")
                            Spacer()
                            Text("\(totalAttempts)")
                                .bold()
                        }
                        
                        HStack {
                            Text("Correct Answers:")
                            Spacer()
                            Text("\(correctAnswers)")
                                .bold()
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("Incorrect Answers:")
                            Spacer()
                            Text("\(totalAttempts - correctAnswers)")
                                .bold()
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Accuracy:")
                            Spacer()
                            Text("\(calculateAccuracy())%")
                                .bold()
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("Best Streak:")
                            Spacer()
                            Text("\(bestStreak)")
                                .bold()
                                .foregroundColor(.orange)
                        }
                    }
                    .padding(.vertical, 4)
                    
                    // Achievement section
                    achievementsSection
                } else {
                    Text("No quiz data yet. Try Quiz Mode to get started!")
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                }
            }
            .padding()
        }
        .navigationTitle("Quiz Stats")
        .onAppear {
            refreshQuizStats()
        }
    }
    
    // Helper function to calculate accuracy with protection against division by zero
    private func calculateAccuracy() -> Int {
        guard totalAttempts > 0 else { return 0 }
        return Int(Double(correctAnswers) / Double(totalAttempts) * 100)
    }
    
    // Helper function to refresh quiz stats from UserDefaults
    private func refreshQuizStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        print("📊 Refreshed quiz stats in QuizStatsView: \(correctAnswers)/\(totalAttempts) attempts, \(bestStreak) best streak")
    }
    
    // MARK: - Achievements Section
    
    var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🏆 Achievements")
                .font(.headline)
                .padding(.top, 12)
            
            let unlockedAchievements = getUnlockedAchievements()
            
            if unlockedAchievements.isEmpty {
                Text("No achievements unlocked yet")
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
            } else {
                ForEach(unlockedAchievements) { achievement in
                    HStack {
                        Image(systemName: achievement.iconName)
                            .font(.headline)
                            .foregroundColor(getColorForIcon(achievement.id))
                        
                        VStack(alignment: .leading) {
                            Text(achievement.title)
                                .fontWeight(.medium)
                            Text(achievement.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func getUnlockedAchievements() -> [QuizAchievement] {
        let accuracy = calculateAccuracy()
        let totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        let userLevel = UserDefaults.standard.integer(forKey: "user_level")
        
        let allAchievements: [QuizAchievement] = [
            // Beginner achievements
            QuizAchievement(
                id: "starter",
                title: "Quiz Novice",
                description: "Answered 10 questions",
                iconName: "1.circle"
            ),
            QuizAchievement(
                id: "beginner",
                title: "Language Apprentice",
                description: "Answered 25 questions",
                iconName: "books.vertical"
            ),
            
            // Streak achievements
            QuizAchievement(
                id: "hotstreak",
                title: "On Fire",
                description: "5 correct answers in a row",
                iconName: "flame"
            ),
            QuizAchievement(
                id: "inferno",
                title: "Unstoppable",
                description: "10 correct answers in a row",
                iconName: "flame.fill"
            ),
            
            // Accuracy achievements
            QuizAchievement(
                id: "accurate",
                title: "Sharp Mind",
                description: "80% accuracy with at least 20 attempts",
                iconName: "brain"
            ),
            QuizAchievement(
                id: "brainiac",
                title: "Brainiac",
                description: "90% accuracy over 50 questions",
                iconName: "graduationcap"
            ),
            QuizAchievement(
                id: "perfect",
                title: "Perfect Recall",
                description: "100% accuracy with at least 15 attempts",
                iconName: "checkmark.seal.fill"
            ),
            
            // Mastery achievements
            QuizAchievement(
                id: "dedicated",
                title: "Dedicated Scholar",
                description: "Completed 100 quiz questions",
                iconName: "books.vertical.fill"
            ),
            QuizAchievement(
                id: "master",
                title: "Language Master",
                description: "Answered 250 questions with 85%+ accuracy",
                iconName: "crown.fill"
            ),
            
            // Special achievements
            QuizAchievement(
                id: "comeback",
                title: "Comeback Kid",
                description: "Get a question right after 3 wrong answers",
                iconName: "arrow.up.heart"
            ),
            QuizAchievement(
                id: "speedster",
                title: "Quick Thinker",
                description: "Answer 10 questions in under 2 minutes",
                iconName: "bolt.fill"
            ),
            
            // XP-based achievements
            QuizAchievement(
                id: "level_5",
                title: "Level 5 Reached",
                description: "Earn 500 XP total",
                iconName: "star.fill"
            ),
            QuizAchievement(
                id: "level_10",
                title: "Dedicated Learner",
                description: "Earn 1,000 XP total",
                iconName: "flame.fill"
            ),
            QuizAchievement(
                id: "xp_milestone_100",
                title: "First Steps",
                description: "Earn your first 100 XP",
                iconName: "figure.walk"
            ),
            QuizAchievement(
                id: "xp_milestone_2500",
                title: "XP Champion",
                description: "Accumulate 2,500 XP",
                iconName: "trophy.fill"
            ),
            QuizAchievement(
                id: "word_master",
                title: "Word Master",
                description: "Reach level 15",
                iconName: "crown.fill"
            )
        ]
        
        return allAchievements.filter { achievement in
            switch achievement.id {
                case "starter": return correctAnswers >= 10
                case "beginner": return correctAnswers >= 25
                case "hotstreak": return bestStreak >= 5
                case "inferno": return bestStreak >= 10
                case "accurate": return accuracy >= 80 && totalAttempts >= 20
                case "brainiac": return accuracy >= 90 && totalAttempts >= 50
                case "perfect": return correctAnswers >= 15 && correctAnswers == totalAttempts
                case "dedicated": return totalAttempts >= 100
                case "master": return totalAttempts >= 250 && Double(correctAnswers) / Double(totalAttempts) >= 0.85
                case "comeback": return UserDefaults.standard.bool(forKey: "quiz_comeback")
                case "speedster": return UserDefaults.standard.bool(forKey: "quiz_speedster")
                // XP-based achievements
                case "level_5": return userLevel >= 5 || totalXP >= 500
                case "level_10": return userLevel >= 10 || totalXP >= 1000
                case "xp_milestone_100": return totalXP >= 100
                case "xp_milestone_2500": return totalXP >= 2500
                case "word_master": return userLevel >= 15
                default: return false
            }
        }
    }
    
    private func getColorForIcon(_ id: String) -> Color {
        switch id {
            case "starter", "beginner": return .green
            case "hotstreak", "inferno": return .orange
            case "accurate", "brainiac", "perfect": return .blue
            case "dedicated", "master": return .purple
            case "comeback": return .red
            case "speedster": return .yellow
            // XP-based achievement colors
            case "level_5", "level_10": return .yellow
            case "xp_milestone_100": return .green
            case "xp_milestone_2500", "word_master": return .purple
            default: return .blue
        }
    }
}

#Preview {
    QuizStatsView()
} 
