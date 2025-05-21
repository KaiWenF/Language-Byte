import XCTest
import Foundation
@testable import Language_Byte_Watch_App

class ModelTests: XCTestCase {
    
    // MARK: - WordPair Tests
    
    func testWordPairInitialization() {
        // Arrange
        let id = "test_id_1"
        let sourceWord = "hola"
        let targetWord = "hello"
        let category = "greetings"
        let lastAttempted: Date? = nil
        
        // Act
        let wordPair = WordPair(id: id, sourceWord: sourceWord, targetWord: targetWord, category: category, lastAttempted: lastAttempted)
        
        // Assert
        XCTAssertEqual(wordPair.id, id)
        XCTAssertEqual(wordPair.sourceWord, sourceWord)
        XCTAssertEqual(wordPair.targetWord, targetWord)
        XCTAssertEqual(wordPair.category, category)
        XCTAssertEqual(wordPair.lastAttempted, lastAttempted)
    }
    
    func testWordPairEquality() {
        // Arrange
        let wordPair1 = WordPair(id: "1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil)
        let wordPair2 = WordPair(id: "1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil) // Same ID and content
        let wordPair3 = WordPair(id: "2", sourceWord: "adios", targetWord: "goodbye", category: "greetings", lastAttempted: nil) // Different ID
        let wordPair4 = WordPair(id: "1", sourceWord: "hola", targetWord: "bonjour", category: "greetings", lastAttempted: nil) // Same ID, different content (equality is based on ID)

        // Assert
        XCTAssertEqual(wordPair1, wordPair2)
        XCTAssertNotEqual(wordPair1, wordPair3)
        XCTAssertEqual(wordPair1, wordPair4) // Should be equal as ID is the same, equality doesn't check content beyond ID by default
    }
    
    func testWordPairHashable() {
        // Arrange
        let wordPair1 = WordPair(id: "hash_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil)
        let wordPair2 = WordPair(id: "hash_2", sourceWord: "adios", targetWord: "goodbye", category: "greetings", lastAttempted: nil)
        
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
        let wordPair = WordPair(id: "codable_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: Date())
        
        // Act
        let encoder = JSONEncoder()
        let data = try encoder.encode(wordPair)
        let decoder = JSONDecoder()
        let decodedWordPair = try decoder.decode(WordPair.self, from: data)
        
        // Assert
        XCTAssertEqual(wordPair, decodedWordPair)
        XCTAssertEqual(wordPair.sourceWord, decodedWordPair.sourceWord)
        XCTAssertEqual(wordPair.targetWord, decodedWordPair.targetWord)
        XCTAssertEqual(wordPair.category, decodedWordPair.category)
        // Optional: Compare dates with tolerance if needed, or ensure both are nil/non-nil
        XCTAssertEqual(wordPair.lastAttempted?.timeIntervalSince1970, decodedWordPair.lastAttempted?.timeIntervalSince1970)
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
            WordPair(id: "lp_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil),
            WordPair(id: "lp_2", sourceWord: "adios", targetWord: "goodbye", category: "greetings", lastAttempted: nil)
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
            pairs: [WordPair(id: "eq_1", sourceWord: "hola", targetWord: "hello", category: "greetings", lastAttempted: nil)]
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