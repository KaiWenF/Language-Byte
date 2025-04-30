import Testing
import SwiftUI
@testable import Language_Byte

struct QuizStatsViewTests {
    
    // Helper function to reset achievement-related UserDefaults
    func resetAchievementDefaults() {
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(false, forKey: "quiz_comeback")
        UserDefaults.standard.set(false, forKey: "quiz_speedster")
    }
    
    // Test the basic UI elements of QuizStatsView
    @Test func testQuizStatsBasicUI() async throws {
        // Setup
        resetAchievementDefaults()
        let statsView = QuizStatsView()
        
        // Verify basic UI elements are present
        #expect(try await ViewInspector.inspect(statsView).find(ViewType.Text.self).string().contains("Quiz Stats"))
        
        // With no stats, should show "No quiz data yet" message
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "No quiz data yet").exists())
        
        // Should have achievements section title
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Achievements").exists())
    }
    
    // Test stats display with data
    @Test func testStatsDisplayWithData() async throws {
        // Setup
        resetAchievementDefaults()
        
        // Set some stats
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(5, forKey: "quiz_bestStreak")
        
        let statsView = QuizStatsView()
        
        // Should show correct stats
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Questions Attempted: 20").exists())
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Correct Answers: 15").exists())
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Incorrect Answers: 5").exists())
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Accuracy: 75%").exists())
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Best Streak: 5").exists())
    }
    
    // Test achievements display
    @Test func testAchievementsDisplay() async throws {
        // Setup with stats that should unlock some achievements
        resetAchievementDefaults()
        
        // Set stats to unlock Quiz Novice, On Fire
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(5, forKey: "quiz_bestStreak")
        
        let statsView = QuizStatsView()
        
        // Achievements section should exist
        let achievementsSection = try await ViewInspector.inspect(statsView).find(viewWithId: "achievementsSection")
        #expect(achievementsSection != nil)
        
        // Should find unlocked achievements
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "Quiz Novice").exists())
        #expect(try await ViewInspector.inspect(statsView).find(textWithString: "On Fire").exists())
        
        // Verify icons are displayed
        let flameIcon = try await ViewInspector.inspect(statsView).find(ImageWithSystemName: "flame")
        #expect(flameIcon != nil, "Flame icon should be displayed for On Fire achievement")
        
        // Locked achievements should be dimmed
        let lockedAchievement = try await ViewInspector.inspect(statsView)
            .find(viewWithId: "achievementRow-brainiac")
        
        #expect(lockedAchievement.opacity == 0.4, "Locked achievements should be dimmed")
    }
    
    // Test achievement icon colors
    @Test func testAchievementIconColors() async throws {
        // Setup
        resetAchievementDefaults()
        
        // Unlock multiple achievements of different types
        UserDefaults.standard.set(100, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(90, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(10, forKey: "quiz_bestStreak")
        
        let statsView = QuizStatsView()
        
        // Check colors for different achievement types
        let beginnerIcon = try await ViewInspector.inspect(statsView)
            .find(viewWithId: "achievementIcon-starter")
        #expect(beginnerIcon.foregroundColor == .green, "Beginner achievements should be green")
        
        let streakIcon = try await ViewInspector.inspect(statsView)
            .find(viewWithId: "achievementIcon-hotstreak")
        #expect(streakIcon.foregroundColor == .orange, "Streak achievements should be orange")
        
        let accuracyIcon = try await ViewInspector.inspect(statsView)
            .find(viewWithId: "achievementIcon-accurate")
        #expect(accuracyIcon.foregroundColor == .blue, "Accuracy achievements should be blue")
        
        let masteryIcon = try await ViewInspector.inspect(statsView)
            .find(viewWithId: "achievementIcon-dedicated")
        #expect(masteryIcon.foregroundColor == .purple, "Mastery achievements should be purple")
    }
} 