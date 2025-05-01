import XCTest
import Foundation
@testable import Language_Byte_Watch_App

class ModelTests: XCTestCase {
    
    // MARK: - WordPair Tests
    
    func testWordPairInitialization() {
        // Arrange
        let foreignWord = "hola"
        let translation = "hello"
        let category = "greetings"
        
        // Act
        let wordPair = WordPair(foreignWord: foreignWord, translation: translation, category: category)
        
        // Assert
        XCTAssertEqual(wordPair.foreignWord, foreignWord)
        XCTAssertEqual(wordPair.translation, translation)
        XCTAssertEqual(wordPair.category, category)
    }
    
    func testWordPairEquality() {
        // Arrange
        let wordPair1 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair2 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair3 = WordPair(foreignWord: "adios", translation: "goodbye", category: "greetings")
        
        // Assert
        XCTAssertEqual(wordPair1, wordPair2)
        XCTAssertNotEqual(wordPair1, wordPair3)
    }
    
    func testWordPairHashable() {
        // Arrange
        let wordPair1 = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        let wordPair2 = WordPair(foreignWord: "adios", translation: "goodbye", category: "greetings")
        
        // Act
        var dictionary = [WordPair: String]()
        dictionary[wordPair1] = "Greeting"
        dictionary[wordPair2] = "Farewell"
        
        // Assert
        XCTAssertEqual(dictionary[wordPair1], "Greeting")
        XCTAssertEqual(dictionary[wordPair2], "Farewell")
    }
    
    func testWordPairCodable() throws {
        // Arrange
        let wordPair = WordPair(foreignWord: "hola", translation: "hello", category: "greetings")
        
        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(wordPair)
        let decoder = JSONDecoder()
        let decodedWordPair = try decoder.decode(WordPair.self, from: data)
        
        // Assert
        XCTAssertEqual(wordPair, decodedWordPair)
    }
    
    // MARK: - Language Tests
    
    func testLanguageInitialization() {
        // Arrange & Act
        let language = Language(code: "fr", name: "French", speechCode: "fr-FR")
        
        // Assert
        XCTAssertEqual(language.code, "fr")
        XCTAssertEqual(language.name, "French")
        XCTAssertEqual(language.speechCode, "fr-FR")
    }
    
    func testLanguagePresets() {
        // Act & Assert
        XCTAssertEqual(Language.english.code, "en")
        XCTAssertEqual(Language.spanish.name, "Spanish")
        XCTAssertEqual(Language.french.speechCode, "fr-FR")
        XCTAssertGreaterThanOrEqual(Language.allLanguages.count, 10) // Should have at least 10 predefined languages now
    }
    
    func testNewlyAddedLanguages() {
        // Test Korean
        XCTAssertEqual(Language.korean.code, "ko")
        XCTAssertEqual(Language.korean.name, "Korean")
        XCTAssertEqual(Language.korean.speechCode, "ko-KR")
        
        // Test Haitian Creole
        XCTAssertEqual(Language.haitianCreole.code, "ht")
        XCTAssertEqual(Language.haitianCreole.name, "Haitian Creole")
        XCTAssertEqual(Language.haitianCreole.speechCode, "ht-HT")
        
        // Test Portuguese
        XCTAssertEqual(Language.portuguese.code, "pt")
        XCTAssertEqual(Language.portuguese.name, "Portuguese")
        XCTAssertEqual(Language.portuguese.speechCode, "pt-BR")
        
        // Make sure all languages are in allLanguages
        let allLanguageCodes = Language.allLanguages.map { $0.code }
        XCTAssertTrue(allLanguageCodes.contains("ko"))
        XCTAssertTrue(allLanguageCodes.contains("ht"))
        XCTAssertTrue(allLanguageCodes.contains("pt"))
    }
    
    // MARK: - LanguagePair Tests
    
    func testLanguagePairInitialization() {
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
        XCTAssertEqual(languagePair.sourceLanguage, source)
        XCTAssertEqual(languagePair.targetLanguage, target)
        XCTAssertEqual(languagePair.pairs.count, 2)
    }
    
    func testLanguagePairID() {
        // Arrange
        let pair = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.spanish,
            pairs: []
        )
        
        // Act
        let id = pair.id
        
        // Assert
        XCTAssertEqual(id, "en-es")
    }
    
    func testLanguagePairEquality() {
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
        XCTAssertEqual(pair1, pair2) // Same id (en-es) despite different number of pairs
        XCTAssertNotEqual(pair1, pair3) // Different id (en-es vs en-fr)
    }
    
    func testPreviouslyUnavailableLanguagePairs() {
        // Test English → Italian
        let englishItalian = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.italian,
            pairs: []
        )
        XCTAssertEqual(englishItalian.id, "en-it")
        
        // Test English → Japanese
        let englishJapanese = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.japanese,
            pairs: []
        )
        XCTAssertEqual(englishJapanese.id, "en-ja")
        
        // Test English → Chinese
        let englishChinese = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.chinese,
            pairs: []
        )
        XCTAssertEqual(englishChinese.id, "en-zh")
    }
    
    func testNewLanguagePairs() {
        // Test English → Korean
        let englishKorean = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.korean,
            pairs: []
        )
        XCTAssertEqual(englishKorean.id, "en-ko")
        
        // Test English → Haitian Creole
        let englishHaitianCreole = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.haitianCreole,
            pairs: []
        )
        XCTAssertEqual(englishHaitianCreole.id, "en-ht")
        
        // Test English → Portuguese
        let englishPortuguese = LanguagePair(
            sourceLanguage: Language.english,
            targetLanguage: Language.portuguese,
            pairs: []
        )
        XCTAssertEqual(englishPortuguese.id, "en-pt")
    }
} 