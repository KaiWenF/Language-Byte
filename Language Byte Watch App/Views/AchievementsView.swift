import SwiftUI
import Foundation

// Local achievement struct with a different name to avoid conflicts with QuizStatsView
struct AchievementItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    var unlocked: Bool = false
}

struct AchievementsView: View {
    @State private var totalAttempts: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var bestStreak: Int = 0
    @State private var unlockedIds: Set<String> = []
    @State private var imageCache: [String: Bool] = [:]
    
    // Track newly unlocked achievements for special animations
    @State private var newlyUnlockedIds: Set<String> = []
    @State private var animatedIds: Set<String> = []  // Keep track of already animated badges
    @State private var initialLoad: Bool = true
    
    // Define all achievements
    let allAchievements: [AchievementItem] = [
        // Beginner achievements
        AchievementItem(id: "starter", title: "Quiz Novice", description: "Answered 10 questions", iconName: "1.circle"),
        AchievementItem(id: "beginner", title: "Language Apprentice", description: "Answered 25 questions", iconName: "books.vertical"),
        
        // Streak achievements
        AchievementItem(id: "hotstreak", title: "On Fire", description: "5 correct answers in a row", iconName: "flame"),
        AchievementItem(id: "inferno", title: "Unstoppable", description: "10 correct answers in a row", iconName: "flame.fill"),
        
        // Accuracy achievements
        AchievementItem(id: "accurate", title: "Sharp Mind", description: "80% accuracy with at least 20 attempts", iconName: "brain"),
        AchievementItem(id: "brainiac", title: "Brainiac", description: "90% accuracy over 50 questions", iconName: "graduationcap"),
        AchievementItem(id: "perfect", title: "Perfect Recall", description: "100% accuracy with at least 15 attempts", iconName: "checkmark.seal.fill"),
        
        // Mastery achievements
        AchievementItem(id: "dedicated", title: "Dedicated Scholar", description: "Completed 100 quiz questions", iconName: "books.vertical.fill"),
        AchievementItem(id: "master", title: "Language Master", description: "Answered 250 questions with 85%+ accuracy", iconName: "crown.fill"),
        
        // Special achievements
        AchievementItem(id: "comeback", title: "Comeback Kid", description: "Get a question right after 3 wrong answers", iconName: "arrow.up.heart"),
        AchievementItem(id: "speedster", title: "Quick Thinker", description: "Answer 10 questions in under 2 minutes", iconName: "bolt.fill"),
        
        // XP-based achievements
        AchievementItem(id: "level_5", title: "Level 5 Reached", description: "Earn 500 XP total", iconName: "star.fill"),
        AchievementItem(id: "level_10", title: "Dedicated Learner", description: "Earn 1,000 XP total", iconName: "flame.fill"),
        AchievementItem(id: "xp_milestone_100", title: "First Steps", description: "Earn your first 100 XP", iconName: "figure.walk"),
        AchievementItem(id: "xp_milestone_2500", title: "XP Champion", description: "Accumulate 2,500 XP", iconName: "trophy.fill"),
        AchievementItem(id: "word_master", title: "Word Master", description: "Reach level 15", iconName: "crown.fill")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("🏅 All Achievements")
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 4)

                ForEach(allAchievements) { achievement in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            badgeImage(for: achievement)
                                .frame(width: 32, height: 32)
                                // Add special effects for newly unlocked achievements
                                .scaleEffect(newlyUnlockedIds.contains(achievement.id) ? 1.1 : 1.0)
                                .overlay(
                                    Circle()
                                        .stroke(
                                            newlyUnlockedIds.contains(achievement.id) 
                                                ? getColorForIcon(achievement.id).opacity(0.6) 
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                        .scaleEffect(1.2)
                                        .opacity(newlyUnlockedIds.contains(achievement.id) ? 1 : 0)
                                        .animation(
                                            newlyUnlockedIds.contains(achievement.id) 
                                                ? Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true) 
                                                : .default,
                                            value: newlyUnlockedIds.contains(achievement.id)
                                        )
                                )
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: newlyUnlockedIds.contains(achievement.id))
                                .animation(.easeOut(duration: 0.4), value: unlockedIds.contains(achievement.id))

                            VStack(alignment: .leading) {
                                Text(achievement.title)
                                    .fontWeight(.medium)
                                Text(achievement.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            Image(systemName: unlockedIds.contains(achievement.id) ? "checkmark.circle.fill" : "lock.circle")
                                .foregroundColor(unlockedIds.contains(achievement.id) ? .green : .gray)
                                .transition(.scale.combined(with: .opacity))
                                .id("status-\(achievement.id)-\(unlockedIds.contains(achievement.id))")
                        }
                        
                        // Show progress bar only for locked achievements
                        if !unlockedIds.contains(achievement.id) {
                            VStack(alignment: .leading, spacing: 2) {
                                ProgressView(value: progressValue(for: achievement.id))
                                    .progressViewStyle(LinearProgressViewStyle())
                                    .frame(height: 4)
                                    .tint(getColorForIcon(achievement.id))
                                
                                Text("\(Int(progressValue(for: achievement.id) * 100))% Complete")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 40) // Align with text content
                            .transition(.opacity)
                            .animation(.easeOut, value: !unlockedIds.contains(achievement.id))
                        }
                    }
                    .padding(.vertical, 6)
                    // Add transition for the entire achievement item
                    .opacity(unlockedIds.contains(achievement.id) ? 1.0 : 0.8)
                    .animation(.easeOut(duration: 0.3), value: unlockedIds.contains(achievement.id))
                }
            }
            .padding()
        }
        .navigationTitle("Achievements")
        .onAppear {
            refreshStats()
        }
    }
    
    // Calculate progress value (0.0 to 1.0) for each achievement
    private func progressValue(for id: String) -> Double {
        let totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        let userLevel = UserDefaults.standard.integer(forKey: "user_level")
        
        switch id {
            case "starter":
                return min(Double(correctAnswers) / 10.0, 1.0)
                
            case "beginner":
                return min(Double(correctAnswers) / 25.0, 1.0)
                
            case "hotstreak":
                return min(Double(bestStreak) / 5.0, 1.0)
                
            case "inferno":
                return min(Double(bestStreak) / 10.0, 1.0)
                
            case "accurate":
                let currentAccuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) * 100 : 0
                let attemptsProgress = min(Double(totalAttempts) / 20.0, 1.0)
                let accuracyProgress = min(currentAccuracy / 80.0, 1.0)
                // Need both criteria, weight them equally
                return (attemptsProgress + accuracyProgress) / 2.0
                
            case "brainiac":
                let currentAccuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) * 100 : 0
                let attemptsProgress = min(Double(totalAttempts) / 50.0, 1.0)
                let accuracyProgress = min(currentAccuracy / 90.0, 1.0)
                return (attemptsProgress + accuracyProgress) / 2.0
                
            case "perfect":
                let currentAccuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) * 100 : 0
                let attemptsProgress = min(Double(correctAnswers) / 15.0, 1.0)
                let accuracyProgress = min(currentAccuracy / 100.0, 1.0)
                return (attemptsProgress + accuracyProgress) / 2.0
                
            case "dedicated":
                return min(Double(totalAttempts) / 100.0, 1.0)
                
            case "master":
                let currentAccuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) * 100 : 0
                let attemptsProgress = min(Double(totalAttempts) / 250.0, 1.0)
                let accuracyProgress = min(currentAccuracy / 85.0, 1.0)
                return (attemptsProgress + accuracyProgress) / 2.0
                
            case "comeback":
                // Special achievement - no meaningful progress to display
                return UserDefaults.standard.bool(forKey: "quiz_comeback_progress") ? 0.5 : 0.0
                
            case "speedster":
                // Special achievement - no meaningful progress to display
                // Could potentially use a UserDefault tracking partial progress
                let speedProgress = UserDefaults.standard.double(forKey: "quiz_speedster_progress")
                return speedProgress > 0 ? speedProgress : 0.0
                
            // XP-based achievements
            case "level_5":
                return min(Double(totalXP) / 500.0, 1.0)
                
            case "level_10":
                return min(Double(totalXP) / 1000.0, 1.0)
                
            case "xp_milestone_100":
                return min(Double(totalXP) / 100.0, 1.0)
                
            case "xp_milestone_2500":
                return min(Double(totalXP) / 2500.0, 1.0)
                
            case "word_master":
                return min(Double(userLevel) / 15.0, 1.0)
                
            default:
                return 0.0
        }
    }
    
    @ViewBuilder
    private func badgeImage(for achievement: AchievementItem) -> some View {
        let isUnlocked = unlockedIds.contains(achievement.id)
        let isNewlyUnlocked = newlyUnlockedIds.contains(achievement.id)
        let unlockedImageName = "\(achievement.id)_badge" 
        let lockedImageName = "\(achievement.id)_badge_locked"
        
        // Custom badge implementation with fallback to SF Symbol
        Group {
            if isCustomImageAvailable(named: isUnlocked ? unlockedImageName : lockedImageName) {
                // Use custom badge image
                Image(isUnlocked ? unlockedImageName : lockedImageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .overlay(
                        Circle()
                            .stroke(isUnlocked ? getColorForIcon(achievement.id) : Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                    // Add glow for newly unlocked badges
                    .shadow(
                        color: isNewlyUnlocked ? getColorForIcon(achievement.id).opacity(0.8) : .clear,
                        radius: isNewlyUnlocked ? 4 : 0
                    )
            } else {
                // Fallback to SF Symbol
                Image(systemName: achievement.iconName)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? getColorForIcon(achievement.id) : .gray)
                    .background(
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                    )
                    .overlay(
                        Circle()
                            .stroke(isUnlocked ? getColorForIcon(achievement.id) : Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                    // Add glow for newly unlocked badges
                    .shadow(
                        color: isNewlyUnlocked ? getColorForIcon(achievement.id).opacity(0.8) : .clear,
                        radius: isNewlyUnlocked ? 4 : 0
                    )
            }
        }
        .transition(.scale)
        .id("badge-\(achievement.id)-\(isUnlocked)") // Force view update when unlocked state changes
        .accessibility(label: Text(achievement.title))
    }
    
    private func isCustomImageAvailable(named imageName: String) -> Bool {
        // Check if we've already determined if this image exists
        if let exists = imageCache[imageName] {
            return exists
        }
        
        // Try loading the image. In a real app, you'd use a more reliable method,
        // but for simplicity, we'll assume the image exists and let SwiftUI handle missing images
        // using its built-in error handling
        let exists = true
        imageCache[imageName] = exists
        return exists
    }
    
    private func refreshStats() {
        // Store current state for comparison
        let previouslyUnlocked = unlockedIds
        
        // Update stats
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        
        // Get newly unlocked achievements with animation
        withAnimation(.easeOut(duration: 0.4)) {
            let currentlyUnlocked = Set(getUnlockedAchievements().map { $0.id })
            unlockedIds = currentlyUnlocked
            
            // Only track newly unlocked on non-initial load to prevent all achievements from animating at once
            if !initialLoad {
                // Find newly unlocked achievements (in current but not in previous)
                newlyUnlockedIds = currentlyUnlocked.subtracting(previouslyUnlocked)
                
                // Play haptic feedback for new unlocks
                if !newlyUnlockedIds.isEmpty {
                    // Play haptic feedback for Apple Watch
                    // Note: Actual implementation would use WKInterfaceDevice on watchOS
                    // For simplicity, we'll use a comment for now to avoid import issues
                    
                    // In a real app with proper imports:
                    // WKInterfaceDevice.current().play(.notification)
                }
                
                // Schedule removal of newly unlocked highlights after a delay
                if !newlyUnlockedIds.isEmpty {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            newlyUnlockedIds = []
                        }
                    }
                }
            }
        }
        
        // After first load, mark as non-initial
        initialLoad = false
    }
    
    // Reuse logic from QuizStatsView but with our own achievement type
    private func getUnlockedAchievements() -> [AchievementItem] {
        let accuracy = totalAttempts > 0 ? Double(correctAnswers) / Double(totalAttempts) * 100 : 0
        let totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        let userLevel = UserDefaults.standard.integer(forKey: "user_level")
        
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
            case "level_5": return .yellow
            case "level_10": return .orange
            case "xp_milestone_100": return .green
            case "xp_milestone_2500": return .purple
            case "word_master": return .purple
            default: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        AchievementsView()
    }
} 