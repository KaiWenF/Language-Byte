import Testing
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
        WordPair(foreignWord: "hola", translation: "hello", category: "greetings"),
        WordPair(foreignWord: "adiós", translation: "goodbye", category: "greetings"),
        WordPair(foreignWord: "gracias", translation: "thank you", category: "courtesy"),
        WordPair(foreignWord: "por favor", translation: "please", category: "courtesy"),
        WordPair(foreignWord: "manzana", translation: "apple", category: "food"),
        WordPair(foreignWord: "agua", translation: "water", category: "drinks")
    ]
    
    static let englishFrenchWords: [WordPair] = [
        WordPair(foreignWord: "bonjour", translation: "hello", category: "greetings"),
        WordPair(foreignWord: "au revoir", translation: "goodbye", category: "greetings"),
        WordPair(foreignWord: "merci", translation: "thank you", category: "courtesy"),
        WordPair(foreignWord: "s'il vous plaît", translation: "please", category: "courtesy"),
        WordPair(foreignWord: "pomme", translation: "apple", category: "food"),
        WordPair(foreignWord: "eau", translation: "water", category: "drinks")
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