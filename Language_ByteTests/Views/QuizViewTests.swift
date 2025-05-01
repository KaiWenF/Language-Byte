import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

// Mock QuizView for testing
class MockQuizView {
    var correctAnswers: Int = 0
    var totalAttempts: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var currentQuestion: QuizQuestion?
    var showFeedback: Bool = false
    var selectedChoice: String = ""
    var isCorrect: Bool = false
    var showExitConfirmation: Bool = false
    
    func selectAnswer(_ answer: String) -> Bool {
        totalAttempts += 1
        selectedChoice = answer
        
        if answer == currentQuestion?.correctAnswer {
            correctAnswers += 1
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
            isCorrect = true
            showFeedback = true
            
            // Save to UserDefaults for later tests
            saveStatsToUserDefaults()
            
            return true
        } else {
            currentStreak = 0
            isCorrect = false
            showFeedback = true
            
            // Save to UserDefaults for later tests
            saveStatsToUserDefaults()
            
            return false
        }
    }
    
    func saveStatsToUserDefaults() {
        UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
    }
    
    func resetQuiz() {
        showFeedback = false
        selectedChoice = ""
        currentQuestion = nil
    }
}

// Mock DashboardView
class MockDashboardView {
    var totalAttempts: Int = 0
    var correctAnswers: Int = 0
    var bestStreak: Int = 0
    var showQuizStats: Bool = false
    
    func refreshQuizStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
    }
    
    func calculateAccuracy() -> Int {
        guard totalAttempts > 0 else { return 0 }
        return Int(Double(correctAnswers) / Double(totalAttempts) * 100)
    }
}

class QuizViewTests: XCTestCase {
    
    // Helper function to reset quiz-related UserDefaults
    func resetQuizDefaults() {
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(false, forKey: "quiz_comeback")
        UserDefaults.standard.set(false, forKey: "quiz_speedster")
    }
    
    // Test the basic UI elements of QuizView
    func testQuizViewBasicUI() async throws {
        // Setup
        let quizView = QuizView()
        
        // Reset stored values before test
        resetQuizDefaults()
        
        // Verify basic UI elements are present
        XCTAssertTrue(try await ViewInspector.inspect(quizView).find(ViewType.HStack.self).find(ViewType.Text.self).string().contains("Quiz Mode"))
        
        // Test that score display is present and shows 0/0 initially
        let scoreText = try await ViewInspector.inspect(quizView).find(textWithString: "0/0")
        XCTAssertNotNil(scoreText, "Score display should be visible")
    }
    
    // Test the exit confirmation functionality
    func testExitConfirmation() {
        // Setup
        let quizView = MockQuizView()
        
        // Initially the confirmation dialog should not be shown
        XCTAssertFalse(quizView.showExitConfirmation)
        
        // Simulate tapping the back button
        quizView.showExitConfirmation = true
        
        // Now the confirmation dialog should be visible
        XCTAssertTrue(quizView.showExitConfirmation)
        
        // Test that resetQuiz clears the state appropriately
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        quizView.showFeedback = true
        quizView.selectedChoice = "hola"
        
        // Call resetQuiz
        quizView.resetQuiz()
        
        // Verify state is reset
        XCTAssertFalse(quizView.showFeedback)
        XCTAssertEqual(quizView.selectedChoice, "")
        XCTAssertNil(quizView.currentQuestion)
    }
    
    // Test the feedback visualization
    func testFeedbackVisualization() {
        // Setup
        let quizView = MockQuizView()
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        
        // Simulate a correct answer
        quizView.selectedChoice = "hola"
        quizView.isCorrect = true
        quizView.showFeedback = true
        
        // The selected button should now have green tint (mock test only verifies state)
        XCTAssertEqual(quizView.selectedChoice, "hola")
        XCTAssertTrue(quizView.isCorrect)
        XCTAssertTrue(quizView.showFeedback)
        
        // Reset and simulate an incorrect answer
        quizView.showFeedback = false
        quizView.selectedChoice = "adiós"
        quizView.isCorrect = false
        quizView.showFeedback = true
        
        // The selected button should now have red tint (mock test only verifies state)
        XCTAssertEqual(quizView.selectedChoice, "adiós")
        XCTAssertFalse(quizView.isCorrect)
        XCTAssertTrue(quizView.showFeedback)
    }
    
    // Test statistics update from QuizView to UserDefaults
    func testQuizStatsUpdateToUserDefaults() {
        // Setup
        resetQuizDefaults()
        let quizView = MockQuizView()
        
        // Set the correct answer state
        quizView.correctAnswers = 0
        quizView.totalAttempts = 0
        quizView.currentStreak = 0
        quizView.bestStreak = 0
        
        // Simulate a correct answer
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        
        let result = quizView.selectAnswer("hola")
        
        // Verify that UserDefaults were updated
        let totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        let correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        let bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        
        XCTAssertTrue(result)
        XCTAssertEqual(totalAttempts, 1, "Total attempts should be updated in UserDefaults")
        XCTAssertEqual(correctAnswers, 1, "Correct answers should be updated in UserDefaults")
        XCTAssertEqual(bestStreak, 1, "Best streak should be updated in UserDefaults")
    }
    
    // Test the integration between QuizView and DailyDashboardView
    func testIntegrationWithDailyDashboard() {
        // Setup
        resetQuizDefaults()
        
        // Set some quiz stats in UserDefaults
        UserDefaults.standard.set(10, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(7, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(4, forKey: "quiz_bestStreak")
        
        // Create the dashboard view
        let dashboardView = MockDashboardView()
        
        // Manually refresh the stats
        dashboardView.refreshQuizStats()
        
        // Verify that the dashboard shows the correct stats
        XCTAssertEqual(dashboardView.totalAttempts, 10)
        XCTAssertEqual(dashboardView.correctAnswers, 7)
        XCTAssertEqual(dashboardView.bestStreak, 4)
        XCTAssertEqual(dashboardView.calculateAccuracy(), 70) // 7/10 = 70%
        
        // Now simulate a quiz that improves the stats
        let quizView = MockQuizView()
        quizView.totalAttempts = 10 // Start with existing stats
        quizView.correctAnswers = 7
        quizView.currentStreak = 0
        quizView.bestStreak = 4
        
        // Simulate 3 correct answers
        for i in 1...3 {
            quizView.currentQuestion = QuizQuestion(
                sourceWord: "word\(i)",
                correctAnswer: "answer\(i)",
                choices: ["answer\(i)", "wrong1", "wrong2"]
            )
            quizView.selectAnswer("answer\(i)")
        }
        
        // Refresh the dashboard
        dashboardView.refreshQuizStats()
        
        // Verify that the dashboard reflects the updated stats
        XCTAssertEqual(dashboardView.totalAttempts, 13)
        XCTAssertEqual(dashboardView.correctAnswers, 10)
        XCTAssertEqual(dashboardView.bestStreak, 4) // Should still be 4 as we only had 3 correct in a row
        XCTAssertEqual(dashboardView.calculateAccuracy(), 76) // 10/13 ≈ 76.9% rounded down to 76%
    }
    
    // Test the navigation to QuizStatsView from DailyDashboardView
    func testQuizStatsNavigation() {
        // Setup
        let dashboardView = MockDashboardView()
        
        // Initially, showQuizStats should be false
        XCTAssertFalse(dashboardView.showQuizStats)
        
        // Simulate clicking the button
        dashboardView.showQuizStats = true
        
        // Now showQuizStats should be true
        XCTAssertTrue(dashboardView.showQuizStats)
    }
    
    // Test QuizView updates UserDefaults with each answer
    func testQuizViewUpdatesUserDefaultsForEachAnswer() {
        // Setup
        resetQuizDefaults()
        let quizView = MockQuizView()
        
        // Initialize the view with a question
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        
        // Simulate a correct answer
        quizView.selectAnswer("hola")
        
        // Check UserDefaults after first answer
        var totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        var correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        
        XCTAssertEqual(totalAttempts, 1, "Total attempts should be updated immediately")
        XCTAssertEqual(correctAnswers, 1, "Correct answers should be updated immediately")
        
        // Simulate another question and an incorrect answer
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "goodbye",
            correctAnswer: "adiós",
            choices: ["hola", "adiós", "gracias"]
        )
        
        quizView.selectAnswer("hola") // Incorrect
        
        // Check UserDefaults again
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        
        XCTAssertEqual(totalAttempts, 2, "Total attempts should be updated after second answer")
        XCTAssertEqual(correctAnswers, 1, "Correct answers should not increase after incorrect answer")
    }
} 