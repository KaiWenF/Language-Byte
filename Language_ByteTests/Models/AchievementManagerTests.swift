import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

class AchievementManagerTests: XCTestCase {
    
    // Helper function to reset achievement-related UserDefaults
    func resetAchievementDefaults() {
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(false, forKey: "quiz_comeback")
        UserDefaults.standard.set(false, forKey: "quiz_speedster")
    }
    
    // Test basic achievement unlocking
    func testBasicAchievements() throws {
        // Reset and setup test data
        resetAchievementDefaults()
        
        // Test with no achievements unlocked
        UserDefaults.standard.set(5, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(3, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(2, forKey: "quiz_bestStreak")
        
        let achievements = AchievementManager.unlockedAchievements(
            correctAnswers: 3,
            bestStreak: 2
        )
        
        // Verify no achievements are unlocked
        for achievement in achievements {
            XCTAssertFalse(achievement.unlocked, "Expected \(achievement.title) to be locked")
        }
        
        // Now simulate unlocking the starter achievement (Quiz Novice - 10 questions answered)
        UserDefaults.standard.set(15, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(10, forKey: "quiz_correctAnswers")
        
        let updatedAchievements = AchievementManager.unlockedAchievements(
            correctAnswers: 10,
            bestStreak: 2
        )
        
        // Find the Quiz Novice achievement
        let quizNovice = updatedAchievements.first { $0.id == "starter" }
        XCTAssertNotNil(quizNovice, "Quiz Novice achievement should exist")
        XCTAssertTrue(quizNovice?.unlocked == true, "Quiz Novice should be unlocked")
        
        // Other achievements should still be locked
        let hotStreak = updatedAchievements.first { $0.id == "hotstreak" }
        XCTAssertFalse(hotStreak?.unlocked == true, "Hot Streak should still be locked")
    }
    
    // Test streak achievements
    func testStreakAchievements() throws {
        // Reset and setup test data
        resetAchievementDefaults()
        
        // Test with streak of 5 (should unlock On Fire)
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers")
        
        let achievements1 = AchievementManager.unlockedAchievements(
            correctAnswers: 15,
            bestStreak: 5 // This should unlock "On Fire"
        )
        
        // Verify On Fire is unlocked
        let onFire = achievements1.first { $0.id == "hotstreak" }
        XCTAssertNotNil(onFire, "On Fire achievement should exist")
        XCTAssertTrue(onFire?.unlocked == true, "On Fire should be unlocked with streak of 5")
        
        // Verify Unstoppable is still locked
        let unstoppable1 = achievements1.first { $0.id == "inferno" }
        XCTAssertFalse(unstoppable1?.unlocked == true, "Unstoppable should still be locked with streak of 5")
        
        // Now test with streak of 10 (should unlock Unstoppable)
        let achievements2 = AchievementManager.unlockedAchievements(
            correctAnswers: 15,
            bestStreak: 10 // This should unlock "Unstoppable"
        )
        
        // Verify Unstoppable is now unlocked
        let unstoppable2 = achievements2.first { $0.id == "inferno" }
        XCTAssertTrue(unstoppable2?.unlocked == true, "Unstoppable should be unlocked with streak of 10")
    }
    
    // Test accuracy achievements
    func testAccuracyAchievements() throws {
        // Reset and setup test data
        resetAchievementDefaults()
        
        // Test Sharp Mind (80% accuracy with at least 20 attempts)
        UserDefaults.standard.set(25, forKey: "quiz_totalAttempts") // 25 attempts
        UserDefaults.standard.set(20, forKey: "quiz_correctAnswers") // 80% accuracy
        
        let achievements = AchievementManager.unlockedAchievements(
            correctAnswers: 20,
            bestStreak: 3
        )
        
        // Verify Sharp Mind is unlocked
        let sharpMind = achievements.first { $0.id == "accurate" }
        XCTAssertTrue(sharpMind?.unlocked == true, "Sharp Mind should be unlocked with 80% accuracy")
        
        // Verify Brainiac is still locked (needs 90% over 50 questions)
        let brainiac = achievements.first { $0.id == "brainiac" }
        XCTAssertFalse(brainiac?.unlocked == true, "Brainiac should be locked without enough attempts")
        
        // Test Perfect Recall (100% with at least 15 attempts)
        UserDefaults.standard.set(15, forKey: "quiz_totalAttempts") // 15 attempts
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers") // 100% accuracy
        
        let perfectAchievements = AchievementManager.unlockedAchievements(
            correctAnswers: 15,
            bestStreak: 3
        )
        
        // Verify Perfect Recall is unlocked
        let perfectRecall = perfectAchievements.first { $0.id == "perfect" }
        XCTAssertTrue(perfectRecall?.unlocked == true, "Perfect Recall should be unlocked with 100% accuracy")
    }
    
    // Test special achievements
    func testSpecialAchievements() throws {
        // Reset and setup test data
        resetAchievementDefaults()
        
        // Test Comeback Kid
        UserDefaults.standard.set(true, forKey: "quiz_comeback")
        
        let achievements = AchievementManager.unlockedAchievements(
            correctAnswers: 10,
            bestStreak: 3
        )
        
        // Verify Comeback Kid is unlocked
        let comebackKid = achievements.first { $0.id == "comeback" }
        XCTAssertTrue(comebackKid?.unlocked == true, "Comeback Kid should be unlocked")
        
        // Test Quick Thinker
        resetAchievementDefaults()
        UserDefaults.standard.set(true, forKey: "quiz_speedster")
        
        let speedsterAchievements = AchievementManager.unlockedAchievements(
            correctAnswers: 10,
            bestStreak: 3
        )
        
        // Verify Quick Thinker is unlocked
        let quickThinker = speedsterAchievements.first { $0.id == "speedster" }
        XCTAssertTrue(quickThinker?.unlocked == true, "Quick Thinker should be unlocked")
    }
    
    // Test achievement icons and colors
    func testAchievementVisuals() throws {
        // Reset and setup test data
        resetAchievementDefaults()
        UserDefaults.standard.set(50, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(45, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(10, forKey: "quiz_bestStreak")
        
        let achievements = AchievementManager.unlockedAchievements(
            correctAnswers: 45,
            bestStreak: 10
        )
        
        // Verify each achievement has a valid icon name
        for achievement in achievements {
            XCTAssertFalse(achievement.iconName.isEmpty, "Achievement \(achievement.id) should have an icon name")
        }
        
        // Check specific icons for key achievements
        let novice = achievements.first { $0.id == "starter" }
        XCTAssertEqual(novice?.iconName, "1.circle", "Quiz Novice should have 1.circle icon")
        
        let onFire = achievements.first { $0.id == "hotstreak" }
        XCTAssertEqual(onFire?.iconName, "flame", "On Fire should have flame icon")
        
        let unstoppable = achievements.first { $0.id == "inferno" }
        XCTAssertEqual(unstoppable?.iconName, "flame.fill", "Unstoppable should have flame.fill icon")
    }
} 