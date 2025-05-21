import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

// Helper extension to make working with ViewModel in views easier for testing
extension View {
    func _viewModel(_ viewModel: WordViewModel) -> some View {
        self.environmentObject(viewModel)
    }
}

// Mock data for testing
struct TestData {
    static let englishSpanishWords: [WordPair] = [
        WordPair(id: "es_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil),
        WordPair(id: "es_2", sourceWord: "adiós", targetWord: "goodbye", category: "greetings", lastAttempted: nil),
        WordPair(id: "es_3", sourceWord: "gracias", targetWord: "thank you", category: "courtesy", lastAttempted: nil),
        WordPair(id: "es_4", sourceWord: "por favor", targetWord: "please", category: "courtesy", lastAttempted: nil),
        WordPair(id: "es_5", sourceWord: "manzana", targetWord: "apple", category: "food", lastAttempted: nil),
        WordPair(id: "es_6", sourceWord: "agua", targetWord: "water", category: "drinks", lastAttempted: nil)
    ]
    
    static let englishFrenchWords: [WordPair] = [
        WordPair(id: "fr_1", sourceWord: "bonjour", targetWord: "hello", category: "greetings", lastAttempted: nil),
        WordPair(id: "fr_2", sourceWord: "au revoir", targetWord: "goodbye", category: "greetings", lastAttempted: nil),
        WordPair(id: "fr_3", sourceWord: "merci", targetWord: "thank you", category: "courtesy", lastAttempted: nil),
        WordPair(id: "fr_4", sourceWord: "s'il vous plaît", targetWord: "please", category: "courtesy", lastAttempted: nil),
        WordPair(id: "fr_5", sourceWord: "pomme", targetWord: "apple", category: "food", lastAttempted: nil),
        WordPair(id: "fr_6", sourceWord: "eau", targetWord: "water", category: "drinks", lastAttempted: nil)
    ]
    
    static let spanishEnglishPair = LanguagePair(
        sourceLanguage: Language.english,
        targetLanguage: Language.spanish,
        pairs: englishSpanishWords
    )
    
    static let frenchEnglishPair = LanguagePair(
        sourceLanguage: Language.english,
        targetLanguage: Language.french,
        pairs: englishFrenchWords
    )
} 