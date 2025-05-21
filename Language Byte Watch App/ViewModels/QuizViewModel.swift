import SwiftUI
import Foundation

class QuizViewModel: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var score: Int = 0
    @Published var attempts: Int = 0
    @Published var currentStreak: Int = 0
    @Published var bestStreak: Int = 0
    
    // Generate a simple quiz question for testing
    func generateQuestion() -> QuizQuestion {
        // Create a basic question with predefined values
        return QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
    }
} 