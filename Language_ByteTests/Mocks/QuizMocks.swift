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
    
    func generateNewQuestion() {
        currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
    }
    
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
    
    func completeQuiz() {
        if totalAttempts >= 10 && correctAnswers >= 8 {
            // Fast completion (under 3 minutes)
            UserDefaults.standard.set(true, forKey: "quiz_speedster")
        }
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