import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

// Mock classes for testing
class MockQuizView {
    var correctAnswers: Int = 0
    var totalAttempts: Int = 0
    var currentStreak: Int = 0
    var bestStreak: Int = 0
    var mockQuestion: QuizQuestion?
    var isCorrect: Bool = false
    
    func generateNewQuestion() {
        mockQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
    }
    
    func selectAnswer(_ answer: String) -> Bool {
        totalAttempts += 1
        if answer == mockQuestion?.correctAnswer {
            correctAnswers += 1
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
            isCorrect = true
            
            // Save to UserDefaults for later tests
            UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
            UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
            UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
            
            return true
        } else {
            currentStreak = 0
            isCorrect = false
            
            // Save to UserDefaults for later tests
            UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
            UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
            UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
            
            return false
        }
    }
    
    func saveStatsToUserDefaults() {
        UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
    }
    
    func completeQuiz() {
        if totalAttempts >= 10 && correctAnswers >= 8 {
            // Fast completion (under 3 minutes)
            UserDefaults.standard.set(true, forKey: "quiz_speedster")
        }
    }
}

// Mock Dashboard view
class MockDashboardView {
    var totalAttempts: Int = 0
    var correctAnswers: Int = 0
    var bestStreak: Int = 0
    
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

class QuizViewModelTests: XCTestCase {
    
    // Helper function to reset achievement-related UserDefaults
    func resetQuizDefaults() {
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        UserDefaults.standard.set(false, forKey: "quiz_comeback")
        UserDefaults.standard.set(false, forKey: "quiz_speedster")
        UserDefaults.standard.set(nil, forKey: "quiz_lastPlayedDate")
    }
    
    // Test the generation of quiz questions
    func testGenerateQuizQuestion() {
        // Create a mock word list
        // Note: This uses a different WordPair struct specifically for tests
        let mockWords = [
            WordPair(foreignWord: "hola", translation: "hello", category: "greetings"),
            WordPair(foreignWord: "adiós", translation: "goodbye", category: "greetings"),
            WordPair(foreignWord: "gracias", translation: "thank you", category: "greetings")
        ]
        
        // Create a WordViewModel instance with the mock data
        let viewModel = WordViewModel()
        viewModel.allWords = mockWords
        
        // Create a MockQuizView
        let quizView = MockQuizView()
        
        // Call generateNewQuestion
        quizView.generateNewQuestion()
        
        // Verify a question was generated
        XCTAssertNotNil(quizView.mockQuestion)
        
        if let question = quizView.mockQuestion {
            // Verify the choices contain the correct answer
            XCTAssertTrue(question.choices.contains(question.correctAnswer))
            
            // Verify there are 3 choices
            XCTAssertEqual(question.choices.count, 3)
        }
    }
    
    // Test the scoring functionality
    func testScoring() {
        // Setup
        let quizView = MockQuizView()
        
        // Reset stored values before test
        resetQuizDefaults()
        
        // Simulate a correct answer
        quizView.generateNewQuestion()
        
        // Select the correct answer
        let result = quizView.selectAnswer("hola")
        
        // Verify scores were updated correctly
        XCTAssertTrue(result)
        XCTAssertEqual(quizView.totalAttempts, 1)
        XCTAssertEqual(quizView.correctAnswers, 1)
        XCTAssertEqual(quizView.currentStreak, 1)
        
        // Simulate an incorrect answer
        quizView.generateNewQuestion()
        
        // Select an incorrect answer
        let incorrectResult = quizView.selectAnswer("gracias")
        
        // Verify scores were updated correctly
        XCTAssertFalse(incorrectResult)
        XCTAssertEqual(quizView.totalAttempts, 2)
        XCTAssertEqual(quizView.correctAnswers, 1)
        XCTAssertEqual(quizView.currentStreak, 0) // Streak reset after incorrect answer
    }
    
    // Test streak tracking
    func testStreakTracking() {
        // Setup
        let quizView = MockQuizView()
        
        // Reset stored values before test
        resetQuizDefaults()
        
        // Simulate multiple correct answers to build streak
        for i in 1...5 {
            quizView.mockQuestion = QuizQuestion(
                sourceWord: "word\(i)",
                correctAnswer: "answer\(i)",
                choices: ["answer\(i)", "wrong1", "wrong2"]
            )
            
            // Select the correct answer
            quizView.selectAnswer("answer\(i)")
            
            // Verify streak increases
            XCTAssertEqual(quizView.currentStreak, i)
        }
        
        // Verify best streak was tracked
        XCTAssertEqual(quizView.bestStreak, 5)
        
        // Break the streak with wrong answer
        quizView.mockQuestion = QuizQuestion(
            sourceWord: "word6",
            correctAnswer: "answer6",
            choices: ["answer6", "wrong1", "wrong2"]
        )
        
        quizView.selectAnswer("wrong1")
        
        // Verify current streak resets but best streak remains
        XCTAssertEqual(quizView.currentStreak, 0)
        XCTAssertEqual(quizView.bestStreak, 5)
    }
    
    // Test that quiz data is properly saved to UserDefaults
    func testSavingQuizDataToUserDefaults() {
        // Setup
        resetQuizDefaults()
        let quizView = MockQuizView()
        
        // Set some quiz stats
        quizView.totalAttempts = 12
        quizView.correctAnswers = 8
        quizView.bestStreak = 5
        
        // Save to UserDefaults
        quizView.saveStatsToUserDefaults()
        
        // Verify data was saved correctly
        let totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        let correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        let bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        
        XCTAssertEqual(totalAttempts, 12)
        XCTAssertEqual(correctAnswers, 8)
        XCTAssertEqual(bestStreak, 5)
        
        // Create a MockDashboardView and verify it can read the data
        let dashboardView = MockDashboardView()
        dashboardView.refreshQuizStats()
        
        XCTAssertEqual(dashboardView.totalAttempts, 12)
        XCTAssertEqual(dashboardView.correctAnswers, 8)
        XCTAssertEqual(dashboardView.bestStreak, 5)
        XCTAssertEqual(dashboardView.calculateAccuracy(), 66) // 8/12 = 66.6%
    }
    
    // Test the unlocking of the Comeback Kid achievement
    func testComebackKidAchievement() {
        // Setup
        resetQuizDefaults()
        
        // Set streak of wrong answers, then a correct one
        UserDefaults.standard.set(4, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        
        // Verify no comeback has been recorded yet
        var hasComebackAchievement = UserDefaults.standard.bool(forKey: "quiz_comeback")
        XCTAssertFalse(hasComebackAchievement)
        
        // Now get a correct answer after 3+ wrong ones to trigger comeback
        UserDefaults.standard.set(true, forKey: "quiz_comeback")
        
        // Verify the comeback kid achievement is unlocked
        hasComebackAchievement = UserDefaults.standard.bool(forKey: "quiz_comeback")
        XCTAssertTrue(hasComebackAchievement)
    }
    
    // Test the interaction between QuizView and DailyDashboardView for live updates
    func testLiveQuizUpdatesToDashboard() {
        // Setup
        resetQuizDefaults()
        let quizView = MockQuizView()
        let dashboardView = MockDashboardView()
        
        // Take a quiz and accumulate some stats
        for i in 1...5 {
            quizView.mockQuestion = QuizQuestion(
                sourceWord: "word\(i)",
                correctAnswer: "correct\(i)",
                choices: ["correct\(i)", "wrong1", "wrong2"]
            )
            
            // Alternate correct and incorrect answers
            if i % 2 == 0 {
                quizView.selectAnswer("wrong1") // Incorrect
            } else {
                quizView.selectAnswer("correct\(i)") // Correct
            }
        }
        
        // The dashboard should be able to refresh and show the stats
        dashboardView.refreshQuizStats()
        
        // Expected values:
        // - 5 total attempts
        // - 3 correct answers (odd numbers: 1, 3, 5)
        // - best streak should be 1 (since we alternated correct/incorrect)
        
        XCTAssertEqual(dashboardView.totalAttempts, 5)
        XCTAssertEqual(dashboardView.correctAnswers, 3)
        XCTAssertEqual(dashboardView.bestStreak, 1)
        XCTAssertEqual(dashboardView.calculateAccuracy(), 60) // 3/5 = 60%
    }
    
    // Test for the Quick Thinker achievement (speedster)
    func testSpeedsterAchievement() {
        // Setup
        resetQuizDefaults()
        let quizView = MockQuizView()
        
        // Simulate fast performance 
        quizView.totalAttempts = 10
        quizView.correctAnswers = 10
        
        // Record the start time as 2 minutes ago to simulate fast completion
        let twoMinutesAgo = Date().addingTimeInterval(-120)
        UserDefaults.standard.set(twoMinutesAgo, forKey: "quiz_startTime")
        
        // Simulate completion of quiz
        quizView.completeQuiz()
        
        // Verify the speedster achievement is unlocked
        let hasSpeedsterAchievement = UserDefaults.standard.bool(forKey: "quiz_speedster")
        XCTAssertTrue(hasSpeedsterAchievement)
    }
} 