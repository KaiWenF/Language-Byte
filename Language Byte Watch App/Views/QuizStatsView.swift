import SwiftUI

// Import the models module where AchievementManager is defined
import Foundation

struct QuizStatsView: View {
    @AppStorage("quiz_totalAttempts") var totalAttempts: Int = 0
    @AppStorage("quiz_correctAnswers") var correctAnswers: Int = 0
    @AppStorage("quiz_bestStreak") var bestStreak: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("📊 Quiz Stats")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 8)

                if totalAttempts > 0 {
                    Text("Questions Attempted: \(totalAttempts)")
                    Text("Correct Answers: \(correctAnswers)")
                    Text("Incorrect Answers: \(totalAttempts - correctAnswers)")
                    Text("Accuracy: \(Int(Double(correctAnswers) / Double(totalAttempts) * 100))%")
                    Text("Best Streak: \(bestStreak)")
                } else {
                    Text("No quiz data yet. Try Quiz Mode to get started!")
                }
                
                achievementsSection
            }
            .padding()
        }
        .navigationTitle("Quiz Stats")
    }
    
    private var achievementsSection: some View {
        let achievements = AchievementManager.unlockedAchievements(
            correctAnswers: correctAnswers,
            bestStreak: bestStreak
        )
        
        return VStack(alignment: .leading, spacing: 10) {
            Text("🏅 Achievements")
                .font(.headline)
                .padding(.top, 16)
                .id("achievementsSection")

            ForEach(achievements) { badge in
                HStack(spacing: 12) {
                    // Achievement icon with background
                    ZStack {
                        Circle()
                            .fill(badge.unlocked ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: badge.unlocked ? badge.iconName : "lock.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)
                            .foregroundColor(badge.unlocked ? getColorForIcon(badge.id) : .gray)
                            .id("achievementIcon-\(badge.id)")
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(badge.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(badge.description)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 4)
                .opacity(badge.unlocked ? 1.0 : 0.4) // Dim locked badges
                .id("achievementRow-\(badge.id)")
            }
        }
        .padding(.top, 12)
    }
    
    // Helper function to get color for each achievement type
    private func getColorForIcon(_ id: String) -> Color {
        switch id {
            case "starter", "beginner": return .green
            case "hotstreak", "inferno": return .orange
            case "accurate", "brainiac", "perfect": return .blue
            case "dedicated", "master": return .purple
            case "comeback": return .red
            case "speedster": return .yellow
            default: return .blue
        }
    }
}

#Preview {
    QuizStatsView()
} 