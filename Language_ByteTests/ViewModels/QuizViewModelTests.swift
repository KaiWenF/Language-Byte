import Testing
import SwiftUI
@testable import Language_Byte

struct QuizViewModelTests {
    
    // Test the generation of quiz questions
    @Test func testGenerateQuizQuestion() async throws {
        // Create a mock word list
        let mockWords = [
            WordPair(foreignWord: "hola", translation: "hello", exampleSentence: "Hola, ¿cómo estás?"),
            WordPair(foreignWord: "adiós", translation: "goodbye", exampleSentence: "Adiós, hasta luego."),
            WordPair(foreignWord: "gracias", translation: "thank you", exampleSentence: "Muchas gracias.")
        ]
        
        // Create a WordViewModel instance with the mock data
        let viewModel = WordViewModel()
        viewModel.allWords = mockWords
        
        // Create a QuizView
        let quizView = QuizView().environmentObject(viewModel)
        
        // Call generateNewQuestion
        await quizView.generateNewQuestion()
        
        // Verify a question was generated
        #expect(quizView.currentQuestion != nil)
        
        if let question = quizView.currentQuestion {
            // Verify the source word is one of our translations
            #expect(["hello", "goodbye", "thank you"].contains(question.sourceWord))
            
            // Verify the choices contain the correct answer
            #expect(question.choices.contains(question.correctAnswer))
            
            // Verify there are 3 choices
            #expect(question.choices.count == 3)
        }
    }
    
    // Test the scoring functionality
    @Test func testScoring() async throws {
        // Setup
        let quizView = QuizView()
        
        // Reset stored values before test
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        
        // Simulate a correct answer
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        
        // Select the correct answer
        await quizView.selectAnswer("hola")
        
        // Verify scores were updated correctly
        #expect(quizView.totalAttempts == 1)
        #expect(quizView.correctAnswers == 1)
        #expect(quizView.currentStreak == 1)
        
        // Simulate an incorrect answer
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "goodbye",
            correctAnswer: "adiós",
            choices: ["hola", "adiós", "gracias"]
        )
        
        // Select an incorrect answer
        await quizView.selectAnswer("hola")
        
        // Verify scores were updated correctly
        #expect(quizView.totalAttempts == 2)
        #expect(quizView.correctAnswers == 1)
        #expect(quizView.currentStreak == 0) // Streak reset after incorrect answer
    }
    
    // Test streak tracking
    @Test func testStreakTracking() async throws {
        // Setup
        let quizView = QuizView()
        
        // Reset stored values before test
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        
        // Simulate multiple correct answers to build streak
        for i in 1...5 {
            quizView.currentQuestion = QuizQuestion(
                sourceWord: "word\(i)",
                correctAnswer: "answer\(i)",
                choices: ["answer\(i)", "wrong1", "wrong2"]
            )
            
            // Select the correct answer
            await quizView.selectAnswer("answer\(i)")
            
            // Verify streak increases
            #expect(quizView.currentStreak == i)
        }
        
        // Verify best streak was tracked
        #expect(quizView.bestStreak == 5)
        
        // Break the streak with wrong answer
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "word6",
            correctAnswer: "answer6",
            choices: ["answer6", "wrong1", "wrong2"]
        )
        
        await quizView.selectAnswer("wrong1")
        
        // Verify current streak resets but best streak remains
        #expect(quizView.currentStreak == 0)
        #expect(quizView.bestStreak == 5)
    }
} 