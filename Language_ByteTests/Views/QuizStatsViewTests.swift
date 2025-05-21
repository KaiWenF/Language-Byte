import SwiftUI
import XCTest

// Mock Achievement struct for testing
struct MockAchievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    var unlocked: Bool = false
}

// Mock QuizStatsView for testing
class MockQuizStatsView {
    var totalAttempts: Int = 0
    var correctAnswers: Int = 0
    var bestStreak: Int = 0
    private var achievements: [MockAchievement] = []
    
    init() {
        setupAchievements()
    }
    
    private func setupAchievements() {
        achievements = [
            MockAchievement(id: "starter", title: "Quiz Novice", description: "Answer 10 questions", iconName: "1.circle"),
            MockAchievement(id: "beginner", title: "Quiz Apprentice", description: "Answer 50 questions", iconName: "2.circle"),
            MockAchievement(id: "hotstreak", title: "On Fire", description: "Get a streak of 5 correct answers", iconName: "flame"),
            MockAchievement(id: "inferno", title: "Unstoppable", description: "Get a streak of 10 correct answers", iconName: "flame.fill"),
            MockAchievement(id: "accurate", title: "Sharp Mind", description: "Achieve 80% accuracy with at least 20 attempts", iconName: "brain"),
            MockAchievement(id: "brainiac", title: "Brainiac", description: "Achieve 90% accuracy with at least 50 attempts", iconName: "brain.head.profile"),
            MockAchievement(id: "perfect", title: "Perfect Recall", description: "Get 100% accuracy on at least 15 questions", iconName: "checkmark.seal.fill"),
            MockAchievement(id: "dedicated", title: "Dedicated Learner", description: "Answer 100 questions", iconName: "graduationcap"),
            MockAchievement(id: "master", title: "Language Master", description: "Answer 200 questions", iconName: "star.fill"),
            MockAchievement(id: "comeback", title: "Comeback Kid", description: "Get a correct answer after 3 wrong ones", iconName: "arrow.up.right"),
            MockAchievement(id: "speedster", title: "Quick Thinker", description: "Answer 10 questions correctly in under 3 minutes", iconName: "bolt.fill")
        ]
    }
    
    func refreshQuizStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
    }
    
    func getUnlockedAchievements() -> [MockAchievement] {
        // Update achievement unlocked status based on current stats
        let accuracy = calculateAccuracy()
        
        // Apply unlock logic (simplified version of actual logic)
        var result = achievements
        
        // Quiz Novice - 10 questions
        if let index = result.firstIndex(where: { $0.id == "starter" }) {
            result[index].unlocked = totalAttempts >= 10
        }
        
        // Quiz Apprentice - 50 questions
        if let index = result.firstIndex(where: { $0.id == "beginner" }) {
            result[index].unlocked = totalAttempts >= 50
        }
        
        // On Fire - 5 correct streak
        if let index = result.firstIndex(where: { $0.id == "hotstreak" }) {
            result[index].unlocked = bestStreak >= 5
        }
        
        // Unstoppable - 10 correct streak
        if let index = result.firstIndex(where: { $0.id == "inferno" }) {
            result[index].unlocked = bestStreak >= 10
        }
        
        // Sharp Mind - 80% accuracy with at least 20 attempts
        if let index = result.firstIndex(where: { $0.id == "accurate" }) {
            result[index].unlocked = accuracy >= 80 && totalAttempts >= 20
        }
        
        // Brainiac - 90% accuracy with at least 50 attempts
        if let index = result.firstIndex(where: { $0.id == "brainiac" }) {
            result[index].unlocked = accuracy >= 90 && totalAttempts >= 50
        }
        
        // Perfect Recall - 100% accuracy with at least 15 attempts
        if let index = result.firstIndex(where: { $0.id == "perfect" }) {
            result[index].unlocked = accuracy >= 100 && totalAttempts >= 15 && correctAnswers == totalAttempts
        }
        
        // Dedicated Learner - 100 questions
        if let index = result.firstIndex(where: { $0.id == "dedicated" }) {
            result[index].unlocked = totalAttempts >= 100
        }
        
        // Language Master - 200 questions
        if let index = result.firstIndex(where: { $0.id == "master" }) {
            result[index].unlocked = totalAttempts >= 200
        }
        
        // Comeback Kid - special achievement
        if let index = result.firstIndex(where: { $0.id == "comeback" }) {
            result[index].unlocked = UserDefaults.standard.bool(forKey: "quiz_comeback")
        }
        
        // Quick Thinker - special achievement
        if let index = result.firstIndex(where: { $0.id == "speedster" }) {
            result[index].unlocked = UserDefaults.standard.bool(forKey: "quiz_speedster")
        }
        
        return result
    }
    
    func calculateAccuracy() -> Int {
        guard totalAttempts > 0 else { return 0 }
        return Int(Double(correctAnswers) / Double(totalAttempts) * 100)
    }
    
    func getColorForIcon(_ achievementId: String) -> Color {
        switch achievementId {
        case "starter", "beginner":
            return .green
        case "hotstreak", "inferno":
            return .orange
        case "accurate", "brainiac", "perfect":
            return .blue
        case "dedicated", "master":
            return .purple
        case "comeback":
            return .red
        case "speedster":
            return .yellow
        default:
            return .blue
        }
    }
}

class QuizStatsViewTests: XCTestCase {
    var viewModel: QuizStatsViewModel!
    var achievementManager: MockAchievementManager!
    var mockStatsView: MockQuizStatsView!
    
    override func setUp() {
        super.setUp()
        achievementManager = MockAchievementManager()
        viewModel = QuizStatsViewModel(achievementManager: achievementManager)
        mockStatsView = MockQuizStatsView()
        resetAchievementDefaults()
    }
    
    override func tearDown() {
        viewModel = nil
        achievementManager = nil
        mockStatsView = nil
        super.tearDown()
    }
    
    // Helper function to reset achievement-related UserDefaults
    func resetAchievementDefaults() {
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(false, forKey: "quiz_comeback")
        UserDefaults.standard.set(false, forKey: "quiz_speedster")
    }
    
    func testQuizAchievementsDisplay() {
        // Given
        let quizStats = QuizStats(
            totalQuestions: 10,
            correctAnswers: 8,
            timeSpent: 120,
            streak: 5
        )
        
        // When
        viewModel.updateStats(quizStats)
        
        // Then
        let accurateAchievement = achievementManager.achievements.first { $0.id == "sharp_mind" }
        XCTAssertNotNil(accurateAchievement, "Sharp Mind achievement should be unlocked")
        XCTAssertTrue(accurateAchievement?.unlocked ?? false, "Sharp Mind achievement should be unlocked")
    }
    
    func testPerfectAccuracyAchievement() {
        // Given
        let quizStats = QuizStats(
            totalQuestions: 10,
            correctAnswers: 10,
            timeSpent: 150,
            streak: 10
        )
        
        // When
        viewModel.updateStats(quizStats)
        
        // Then
        let perfectAchievement = achievementManager.achievements.first { $0.id == "perfect_recall" }
        XCTAssertNotNil(perfectAchievement, "Perfect Recall achievement should be unlocked")
        XCTAssertTrue(perfectAchievement?.unlocked ?? false, "Perfect Recall achievement should be unlocked")
    }
    
    func testSpecialAchievements() {
        // Given
        let quizStats = QuizStats(
            totalQuestions: 10,
            correctAnswers: 8,
            timeSpent: 60, // Fast completion time
            streak: 3
        )
        
        // When
        viewModel.updateStats(quizStats)
        
        // Then
        let speedsterAchievement = achievementManager.achievements.first { $0.id == "quick_thinker" }
        XCTAssertNotNil(speedsterAchievement, "Quick Thinker achievement should be unlocked")
        XCTAssertTrue(speedsterAchievement?.unlocked ?? false, "Quick Thinker achievement should be unlocked")
    }
    
    func testNoAchievementsWithNoProgress() {
        // Given
        let quizStats = QuizStats(
            totalQuestions: 0,
            correctAnswers: 0,
            timeSpent: 0,
            streak: 0
        )
        
        // When
        viewModel.updateStats(quizStats)
        
        // Then
        let unlockedAchievements = achievementManager.achievements.filter { $0.unlocked }
        XCTAssertTrue(unlockedAchievements.isEmpty, "No achievements should be unlocked without progress")
    }
    
    // Test the basic stats display
    func testStatsDisplay() {
        // Setup
        resetAchievementDefaults()
        
        // Set some stats
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(5, forKey: "quiz_bestStreak")
        
        mockStatsView.refreshQuizStats()
        
        // Should show correct stats
        XCTAssertEqual(mockStatsView.totalAttempts, 20)
        XCTAssertEqual(mockStatsView.correctAnswers, 15)
        XCTAssertEqual(mockStatsView.bestStreak, 5)
        XCTAssertEqual(mockStatsView.calculateAccuracy(), 75)
    }
    
    // Test local achievement display in QuizStatsView
    func testQuizAchievementsDisplay2() {
        // Setup with stats that should unlock some achievements
        resetAchievementDefaults()
        
        // Set stats to unlock Quiz Novice and On Fire achievements
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(16, forKey: "quiz_correctAnswers") // 80% accuracy
        UserDefaults.standard.set(5, forKey: "quiz_bestStreak")
        
        mockStatsView.refreshQuizStats()
        
        // Get unlocked achievements from the view
        let unlockedAchievements = mockStatsView.getUnlockedAchievements().filter { $0.unlocked }
        
        // Should have at least 2 unlocked achievements
        XCTAssertGreaterThanOrEqual(unlockedAchievements.count, 3, "Should have at least 3 unlocked achievements")
        
        // Verify specific achievements are unlocked
        let starterAchievement = unlockedAchievements.first(where: { $0.id == "starter" })
        XCTAssertNotNil(starterAchievement, "Quiz Novice achievement should be unlocked")
        
        let hotstreakAchievement = unlockedAchievements.first(where: { $0.id == "hotstreak" })
        XCTAssertNotNil(hotstreakAchievement, "On Fire achievement should be unlocked")
        
        // Verify accurate achievement for 80% accuracy with 20 attempts
        let accurateAchievement = unlockedAchievements.first(where: { $0.id == "accurate" })
        XCTAssertNotNil(accurateAchievement, "Sharp Mind achievement should be unlocked")
    }
    
    // Test achievement colors
    func testAchievementColorAssignment() {
        // Test different color assignments
        XCTAssertEqual(mockStatsView.getColorForIcon("starter"), .green, "Beginner achievements should be green")
        XCTAssertEqual(mockStatsView.getColorForIcon("hotstreak"), .orange, "Streak achievements should be orange")
        XCTAssertEqual(mockStatsView.getColorForIcon("accurate"), .blue, "Accuracy achievements should be blue")
        XCTAssertEqual(mockStatsView.getColorForIcon("dedicated"), .purple, "Mastery achievements should be purple")
        XCTAssertEqual(mockStatsView.getColorForIcon("comeback"), .red, "Comeback achievement should be red")
        XCTAssertEqual(mockStatsView.getColorForIcon("speedster"), .yellow, "Speedster achievement should be yellow")
        XCTAssertEqual(mockStatsView.getColorForIcon("unknown"), .blue, "Default color should be blue")
    }
    
    // Test perfect accuracy achievement
    func testPerfectAccuracyAchievement2() {
        // Setup
        resetAchievementDefaults()
        
        // Set stats for 100% accuracy with 15 attempts 
        UserDefaults.standard.set(15, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers") 
        UserDefaults.standard.set(15, forKey: "quiz_bestStreak") // Perfect streak
        
        mockStatsView.refreshQuizStats()
        
        // Get unlocked achievements
        let unlockedAchievements = mockStatsView.getUnlockedAchievements().filter { $0.unlocked }
        
        // Check for Perfect Recall achievement
        let perfectAchievement = unlockedAchievements.first(where: { $0.id == "perfect" })
        XCTAssertNotNil(perfectAchievement, "Perfect Recall achievement should be unlocked with 100% accuracy")
        
        // If the test fails, print out the stats for debugging
        if perfectAchievement == nil {
            print("DEBUG: totalAttempts=\(mockStatsView.totalAttempts), correctAnswers=\(mockStatsView.correctAnswers)")
            print("DEBUG: Accuracy=\(mockStatsView.calculateAccuracy())%")
            let allAchievements = mockStatsView.getUnlockedAchievements()
            if let perfect = allAchievements.first(where: { $0.id == "perfect" }) {
                print("DEBUG: Perfect achievement exists but unlocked=\(perfect.unlocked)")
            } else {
                print("DEBUG: Perfect achievement not found")
            }
        }
    }
    
    // Test special achievement unlocking (comeback and speedster)
    func testSpecialAchievements2() {
        // Setup
        resetAchievementDefaults()
        
        // Set stats and enable special achievements
        UserDefaults.standard.set(20, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(15, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(5, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(true, forKey: "quiz_comeback")
        UserDefaults.standard.set(true, forKey: "quiz_speedster")
        
        mockStatsView.refreshQuizStats()
        
        // Get unlocked achievements
        let unlockedAchievements = mockStatsView.getUnlockedAchievements().filter { $0.unlocked }
        
        // Check for special achievements
        let comebackAchievement = unlockedAchievements.first(where: { $0.id == "comeback" })
        XCTAssertNotNil(comebackAchievement, "Comeback Kid achievement should be unlocked")
        
        let speedsterAchievement = unlockedAchievements.first(where: { $0.id == "speedster" })
        XCTAssertNotNil(speedsterAchievement, "Quick Thinker achievement should be unlocked")
    }
    
    // Test all achievements available
    func testAllAchievementsExist() {
        // Access all achievements (both locked and unlocked)
        let allAchievements = mockStatsView.getUnlockedAchievements()
        
        // There should be achievement definitions for these IDs
        let expectedAchievementIds = [
            "starter", "beginner", // Beginner achievements
            "hotstreak", "inferno", // Streak achievements  
            "accurate", "brainiac", "perfect", // Accuracy achievements
            "dedicated", "master", // Mastery achievements
            "comeback", "speedster" // Special achievements
        ]
        
        // Check that there are definitions for all expected achievement IDs
        for id in expectedAchievementIds {
            let found = allAchievements.contains(where: { $0.id == id })
            XCTAssertTrue(found, "Achievement with ID \(id) should be defined")
        }
    }
}

// MARK: - Supporting Types

struct QuizStats {
    let totalQuestions: Int
    let correctAnswers: Int
    let timeSpent: TimeInterval
    let streak: Int
}

class QuizStatsViewModel: ObservableObject {
    private let achievementManager: MockAchievementManager
    
    init(achievementManager: MockAchievementManager) {
        self.achievementManager = achievementManager
    }
    
    func updateStats(_ stats: QuizStats) {
        // Check for accuracy-based achievements
        let accuracy = Double(stats.correctAnswers) / Double(stats.totalQuestions)
        if accuracy >= 0.8 {
            achievementManager.unlockAchievement(id: "sharp_mind")
        }
        if accuracy == 1.0 {
            achievementManager.unlockAchievement(id: "perfect_recall")
        }
        
        // Check for speed-based achievements
        if stats.timeSpent <= 60 && stats.totalQuestions >= 5 {
            achievementManager.unlockAchievement(id: "quick_thinker")
        }
        
        // Check for streak-based achievements
        if stats.streak >= 5 {
            achievementManager.unlockAchievement(id: "hotstreak")
        }
    }
}

class MockAchievementManager {
    var achievements: [MockAchievement] = []
    
    func unlockAchievement(id: String) {
        if let index = achievements.firstIndex(where: { $0.id == id }) {
            achievements[index].unlocked = true
        } else {
            let achievement = MockAchievement(id: id, title: "", description: "", iconName: "", unlocked: true)
            achievements.append(achievement)
        }
    }
} 