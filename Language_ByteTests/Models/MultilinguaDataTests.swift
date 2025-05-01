import XCTest
import Foundation
@testable import Language_Byte_Watch_App

class MultilinguaDataTests: XCTestCase {
    
    // Test the structure of the multilingual_words.json file
    func testMultilingualWordsFileStructure() throws {
        // Get the URL to the JSON file
        guard let fileURL = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            XCTFail("multilingual_words.json file not found")
            return
        }
        
        // Read the file data
        let data = try Data(contentsOf: fileURL)
        
        // Try to decode it
        let decoder = JSONDecoder()
        let wordsData = try decoder.decode([String: [String: [String: String]]].self, from: data)
        
        // Verify the top-level keys (language pairs)
        let languagePairs = wordsData.keys
        XCTAssertGreaterThanOrEqual(languagePairs.count, 10, "Should have at least 10 language pairs")
        
        // Verify the structure of each language pair
        for (pairKey, categories) in wordsData {
            // Each pair should have categories
            XCTAssertFalse(categories.isEmpty, "Language pair \(pairKey) should have categories")
            
            // Each category should have word pairs
            for (category, words) in categories {
                XCTAssertFalse(words.isEmpty, "Category \(category) in \(pairKey) should have words")
            }
        }
    }
    
    // Test that the previously unavailable languages are now available
    func testPreviouslyUnavailableLanguages() throws {
        // Get the URL to the JSON file
        guard let fileURL = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            XCTFail("multilingual_words.json file not found")
            return
        }
        
        // Read the file data
        let data = try Data(contentsOf: fileURL)
        
        // Try to decode it
        let decoder = JSONDecoder()
        let wordsData = try decoder.decode([String: [String: [String: String]]].self, from: data)
        
        // Check for previously unavailable language pairs
        XCTAssertTrue(wordsData.keys.contains("en-it"), "English to Italian should be available")
        XCTAssertTrue(wordsData.keys.contains("en-ja"), "English to Japanese should be available")
        XCTAssertTrue(wordsData.keys.contains("en-zh"), "English to Chinese should be available")
        
        // Verify each language pair has data
        if let italianData = wordsData["en-it"] {
            XCTAssertFalse(italianData.isEmpty, "English to Italian should have data")
        } else {
            XCTFail("English to Italian data should exist")
        }
        
        if let japaneseData = wordsData["en-ja"] {
            XCTAssertFalse(japaneseData.isEmpty, "English to Japanese should have data")
        } else {
            XCTFail("English to Japanese data should exist")
        }
        
        if let chineseData = wordsData["en-zh"] {
            XCTAssertFalse(chineseData.isEmpty, "English to Chinese should have data")
        } else {
            XCTFail("English to Chinese data should exist")
        }
    }
    
    // Test the newly added Korean language data
    func testKoreanLanguageData() throws {
        // Get the URL to the JSON file
        guard let fileURL = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            XCTFail("multilingual_words.json file not found")
            return
        }
        
        // Read the file data
        let data = try Data(contentsOf: fileURL)
        
        // Try to decode it
        let decoder = JSONDecoder()
        let wordsData = try decoder.decode([String: [String: [String: String]]].self, from: data)
        
        // Verify Korean language pair exists
        XCTAssertTrue(wordsData.keys.contains("en-ko"), "English to Korean should be available")
        
        // Verify Korean data structure
        guard let koreanData = wordsData["en-ko"] else {
            XCTFail("Korean data should exist")
            return
        }
        
        // Check for standard categories
        let expectedCategories = ["greetings", "common", "food", "family", "numbers", "travel"]
        for category in expectedCategories {
            XCTAssertTrue(koreanData.keys.contains(category), "Korean should have \(category) category")
        }
        
        // Verify specific Korean words
        if let greetings = koreanData["greetings"] {
            XCTAssertNotNil(greetings["hello"], "Korean should have translation for 'hello'")
            XCTAssertNotNil(greetings["goodbye"], "Korean should have translation for 'goodbye'")
        }
        
        if let food = koreanData["food"] {
            XCTAssertGreaterThanOrEqual(food.count, 5, "Korean food category should have at least 5 words")
        }
    }
    
    // Test the newly added Haitian Creole language data
    func testHaitianCreoleLanguageData() throws {
        // Get the URL to the JSON file
        guard let fileURL = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            XCTFail("multilingual_words.json file not found")
            return
        }
        
        // Read the file data
        let data = try Data(contentsOf: fileURL)
        
        // Try to decode it
        let decoder = JSONDecoder()
        let wordsData = try decoder.decode([String: [String: [String: String]]].self, from: data)
        
        // Verify Haitian Creole language pair exists
        XCTAssertTrue(wordsData.keys.contains("en-ht"), "English to Haitian Creole should be available")
        
        // Verify Haitian Creole data structure
        guard let haitianData = wordsData["en-ht"] else {
            XCTFail("Haitian Creole data should exist")
            return
        }
        
        // Check for standard categories
        let expectedCategories = ["greetings", "common", "food", "family", "numbers"]
        for category in expectedCategories {
            XCTAssertTrue(haitianData.keys.contains(category), "Haitian Creole should have \(category) category")
        }
        
        // Verify specific Haitian Creole words
        if let greetings = haitianData["greetings"] {
            XCTAssertNotNil(greetings["hello"], "Haitian Creole should have translation for 'hello'")
            XCTAssertNotNil(greetings["thank you"], "Haitian Creole should have translation for 'thank you'")
        }
        
        if let family = haitianData["family"] {
            XCTAssertGreaterThanOrEqual(family.count, 5, "Haitian Creole family category should have at least 5 words")
            XCTAssertNotNil(family["mother"], "Haitian Creole should have translation for 'mother'")
            XCTAssertNotNil(family["father"], "Haitian Creole should have translation for 'father'")
        }
        
        // Verify numbers are included
        if let numbers = haitianData["numbers"] {
            XCTAssertGreaterThanOrEqual(numbers.count, 10, "Haitian Creole should have at least 10 number translations")
            XCTAssertNotNil(numbers["one"], "Haitian Creole should have translation for 'one'")
            XCTAssertNotNil(numbers["ten"], "Haitian Creole should have translation for 'ten'")
        }
    }
    
    // Test the newly added Portuguese language data
    func testPortugueseLanguageData() throws {
        // Get the URL to the JSON file
        guard let fileURL = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            XCTFail("multilingual_words.json file not found")
            return
        }
        
        // Read the file data
        let data = try Data(contentsOf: fileURL)
        
        // Try to decode it
        let decoder = JSONDecoder()
        let wordsData = try decoder.decode([String: [String: [String: String]]].self, from: data)
        
        // Verify Portuguese language pair exists
        XCTAssertTrue(wordsData.keys.contains("en-pt"), "English to Portuguese should be available")
        
        // Verify Portuguese data structure
        guard let portugueseData = wordsData["en-pt"] else {
            XCTFail("Portuguese data should exist")
            return
        }
        
        // Check for the same categories as Spanish (since it was based on Spanish template)
        guard let spanishData = wordsData["en-es"] else {
            XCTFail("Spanish data should exist for comparison")
            return
        }
        
        // Portuguese should have at least the same categories as Spanish
        for category in spanishData.keys {
            XCTAssertTrue(portugueseData.keys.contains(category), "Portuguese should have \(category) category like Spanish")
        }
        
        // Verify specific Portuguese words
        if let greetings = portugueseData["greetings"] {
            XCTAssertNotNil(greetings["hello"], "Portuguese should have translation for 'hello'")
            XCTAssertNotNil(greetings["goodbye"], "Portuguese should have translation for 'goodbye'")
            XCTAssertNotNil(greetings["good morning"], "Portuguese should have translation for 'good morning'")
        }
        
        if let common = portugueseData["common"] {
            XCTAssertGreaterThanOrEqual(common.count, 10, "Portuguese common category should have at least 10 words")
        }
    }
} 