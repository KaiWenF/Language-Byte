import Foundation

/// Represents a quiz question with the word to translate, correct answer, and choices
public struct QuizQuestion {
    /// The source word to be translated
    public let sourceWord: String
    /// The correct translation
    public let correctAnswer: String
    /// The list of possible answers (includes the correct answer)
    public let choices: [String]
    
    public init(sourceWord: String, correctAnswer: String, choices: [String]) {
        self.sourceWord = sourceWord
        self.correctAnswer = correctAnswer
        self.choices = choices
    }
}

/// Represents difficulty levels for quiz questions
public enum QuizDifficulty {
    case easy
    case medium
    case hard
} 