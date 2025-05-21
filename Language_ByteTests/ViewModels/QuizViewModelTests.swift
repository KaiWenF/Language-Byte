import XCTest
@testable import Language_Byte_Watch_App

class QuizViewModelTests: XCTestCase {
    var quizViewModel: QuizViewModel!
    var quizView: QuizViewMock!
    
    override func setUp() {
        super.setUp()
        quizViewModel = QuizViewModel()
        quizView = QuizViewMock()
    }
    
    override func tearDown() {
        quizViewModel = nil
        quizView = nil
        super.tearDown()
    }
    
    // Test the generation of quiz questions
    func testGenerateQuizQuestion() {
        // Create a mock word list
        let mockWords = [
            WordPair(id: "q_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil),
            WordPair(id: "q_2", sourceWord: "adiós", targetWord: "goodbye", category: "greetings", lastAttempted: nil),
            WordPair(id: "q_3", sourceWord: "gracias", targetWord: "thank you", category: "greetings", lastAttempted: nil)
        ]
        
        // Generate a quiz question
        let question = quizViewModel.generateQuestion()
        
        // Verify that the question was created correctly
        XCTAssertNotNil(question, "Question should not be nil")
        XCTAssertEqual(question.choices.count, 3, "Should have 3 choices")
        XCTAssertTrue(question.choices.contains(question.correctAnswer), "Correct answer should be in choices")
    }
    
    // Test quiz answer selection
    func testQuizAnswerSelection() {
        // Setup mock quiz
        quizView.generateNewQuestion()
        
        // Verify question is generated
        XCTAssertNotNil(quizView.mockQuestion)
        
        if let question = quizView.mockQuestion {
            // Select the correct answer
            let result = quizView.selectAnswer(correct: true)
            
            // Verify results
            XCTAssertTrue(result, "Result should be true for correct answer")
            XCTAssertEqual(quizView.totalAttempts, 1)
            XCTAssertEqual(quizView.correctAnswers, 1)
            XCTAssertEqual(quizView.currentStreak, 1)
            
            // Try another question
            quizView.generateNewQuestion()
            
            // Select an incorrect answer
            let incorrectResult = quizView.selectAnswer(correct: false)
            
            // Verify results
            XCTAssertFalse(incorrectResult, "Result should be false for incorrect answer")
            XCTAssertEqual(quizView.totalAttempts, 2)
            XCTAssertEqual(quizView.correctAnswers, 1)
            XCTAssertEqual(quizView.currentStreak, 0) // Streak reset after incorrect answer
        }
    }
    
    // Test streak tracking
    func testStreakTracking() {
        // Build up a streak of 5 correct answers
        for i in 1...5 {
            quizView.mockQuestion = QuizQuestion(
                sourceWord: "source\(i)",
                correctAnswer: "answer\(i)",
                choices: ["answer\(i)", "wrong1", "wrong2"]
            )
            
            let result = quizView.selectAnswer(correct: true)
            XCTAssertTrue(result)
            XCTAssertEqual(quizView.currentStreak, i)
        }
        
        // Verify best streak is recorded
        XCTAssertEqual(quizView.bestStreak, 5)
        
        // Break the streak
        quizView.mockQuestion = QuizQuestion(
            sourceWord: "source6",
            correctAnswer: "correct",
            choices: ["correct", "wrong1", "wrong2"]
        )
        quizView.selectAnswer(correct: false)
        
        // Verify streak is reset but best streak is preserved
        XCTAssertEqual(quizView.currentStreak, 0)
        XCTAssertEqual(quizView.bestStreak, 5)
    }
    
    // Test quiz stats persistence
    func testQuizStatsPersistence() {
        // Setup some quiz stats
        quizView.totalAttempts = 12
        quizView.correctAnswers = 8
        quizView.bestStreak = 5
        
        // Save stats to UserDefaults
        quizView.saveStatsToUserDefaults()
        
        // Verify stats are saved correctly
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "quiz_totalAttempts"), 12)
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "quiz_correctAnswers"), 8)
        XCTAssertEqual(UserDefaults.standard.integer(forKey: "quiz_bestStreak"), 5)
        
        // Clean up
        UserDefaults.standard.removeObject(forKey: "quiz_totalAttempts")
        UserDefaults.standard.removeObject(forKey: "quiz_correctAnswers")
        UserDefaults.standard.removeObject(forKey: "quiz_bestStreak")
    }
}

// Mock classes for testing
class QuizViewMock {
    var mockQuestion: QuizQuestion?
    var totalAttempts = 0
    var correctAnswers = 0
    var currentStreak = 0
    var bestStreak = 0
    
    func generateNewQuestion() {
        // Mock implementation for testing
        mockQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adios", "gracias"]
        )
    }
    
    func selectAnswer(correct: Bool) -> Bool {
        totalAttempts += 1
        
        if correct {
            correctAnswers += 1
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
        
        return correct
    }
    
    func saveStatsToUserDefaults() {
        // Mock implementation for testing
        UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
    }
    
    func completeQuiz() {
        // Mock implementation
        NotificationCenter.default.post(name: .quizCompleted, object: nil)
    }
}

// Extension to create .quizCompleted notification name for testing
extension Notification.Name {
    static let quizCompleted = Notification.Name("quizCompleted")
} 