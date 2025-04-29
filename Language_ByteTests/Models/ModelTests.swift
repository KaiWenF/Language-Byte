import Testing
import Foundation
@testable import Language_Byte_Watch_App

struct ModelTests {
    
    // MARK: - WordPair Tests
    
    @Test func testWordPairInitialization() {
        // Arrange
        let foreignWord = "hola"
        let translation = "hello"
        let category = "greetings"
        
        // Act
        let wordPair = WordPair(foreignWord: foreignWord, translation: translation, category: category)
        
        // Assert
        #expect(wordPair.foreignWord == foreignWord)
        #expect(wordPair.translation == translation)
        #expect(wordPair.category == category)
    }
    
    @Test func testWordPairEquality() {
        // Arrange
        let wordPair1 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair2 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair3 = WordPair(foreignWord: "adios", translation: "goodbye", category: "greetings")
        
        // Assert
        #expect(wordPair1 == wordPair2)
        #expect(wordPair1 != wordPair3)
    }
    
    @Test func testWordPairHashable() {
        // Arrange
        let wordPair1 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair2 = WordPair(foreignWord: "adios", translation: "goodbye", category: "greetings")
        
        // Act
        var dictionary = [WordPair: String]()
        dictionary[wordPair1] = "Greeting"
        dictionary[wordPair2] = "Farewell"
        
        // Assert
        #expect(dictionary[wordPair1] == "Greeting")
        #expect(dictionary[wordPair2] == "Farewell")
    }
    
    @Test func testWordPairCodable() throws {
        // Arrange
        let wordPair = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        
        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(wordPair)
        let decoder = JSONDecoder()
        let decodedWordPair = try decoder.decode(WordPair.self, from: data)
        
        // Assert
        #expect(wordPair == decodedWordPair)
    }
    
    // MARK: - Language Tests
    
    @Test func testLanguageInitialization() {
        // Arrange & Act
        let language = Language(code: "fr", name: "French", speechCode: "fr-FR")
        
        // Assert
        #expect(language.code == "fr")
        #expect(language.name == "French")
        #expect(language.speechCode == "fr-FR")
    }
    
    @Test func testLanguagePresets() {
        // Act & Assert
        #expect(Language.english.code == "en")
        #expect(Language.spanish.name == "Spanish")
        #expect(Language.french.speechCode == "fr-FR")
        #expect(Language.allLanguages.count >= 7) // Should have at least the predefined languages
    }
    
    // MARK: - LanguagePair Tests
    
    @Test func testLanguagePairInitialization() {
        // Arrange
        let source = Language.english
        let target = Language.spanish
        let pairs = [
            WordPair(foreignWord: "hola", translation: "hello", category: "greetings"),
            WordPair(foreignWord: "adios", translation: "goodbye", category: "greetings")
        ]
        
        // Act
        let languagePair = LanguagePair(sourceLanguage: source, targetLanguage: target, pairs: pairs)
        
        // Assert
        #expect(languagePair.sourceLanguage == source)
        #expect(languagePair.targetLanguage == target)
        #expect(languagePair.pairs.count == 2)
    }
    
    @Test func testLanguagePairID() {
        // Arrange
        let pair = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.spanish,
            pairs: []
        )
        
        // Act
        let id = pair.id
        
        // Assert
        #expect(id == "en-es")
    }
    
    @Test func testLanguagePairEquality() {
        // Arrange
        let pair1 = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.spanish,
            pairs: []
        )
        
        let pair2 = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.spanish,
            pairs: [WordPair(foreignWord: "hola", translation: "hello", category: "greetings")]
        )
        
        let pair3 = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.french,
            pairs: []
        )
        
        // Assert
        #expect(pair1 == pair2) // Same id (en-es) despite different number of pairs
        #expect(pair1 != pair3) // Different id (en-es vs en-fr)
    }
} 