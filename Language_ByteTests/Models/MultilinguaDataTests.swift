import XCTest
import Foundation
@testable import Language_Byte_Watch_App

class MultilinguaDataTests: XCTestCase {
    
    // Language pair structure from JSON
    struct LanguagePair: Codable {
        let source: String
        let target: String
        let name: LanguageName
        let pairs: [WordPair]
    }
    
    struct LanguageName: Codable {
        let source: String
        let target: String
    }
    
    struct WordPair: Codable {
        let sourceWord: String
        let targetWord: String
        let category: String
    }
    
    struct MultilingualData: Codable {
        let languages: [LanguagePair]
    }
    
    // Helper function to get the test data
    private func loadMultilingualData() throws -> MultilingualData {
        // First look for the file in the main app bundle
        var fileURL: URL?
        
        // Try to find the JSON file in different possible bundle locations
        let possibleBundles = [
            Bundle(for: type(of: self)),  // Test bundle
            Bundle.main,                  // Main bundle
            Bundle(identifier: "com.example.Language-Byte-Watch-App") // App bundle by identifier
        ]
        
        for bundle in possibleBundles {
            if let url = bundle?.url(forResource: "multilingual_words", withExtension: "json") {
                fileURL = url
                break
            }
        }
        
        // If not found in main bundles, try to construct the path manually
        if fileURL == nil {
            let projectDir = URL(fileURLWithPath: #file)
                .deletingLastPathComponent() // Models
                .deletingLastPathComponent() // Language_ByteTests
            
            // Try app targets
            let appURL = projectDir.appendingPathComponent("Language Byte Watch App/multilingual_words.json")
            
            if FileManager.default.fileExists(atPath: appURL.path) {
                fileURL = appURL
            }
        }
        
        guard let url = fileURL else {
            XCTFail("multilingual_words.json file not found in any bundle")
            throw NSError(domain: "MultilinguaDataTests", code: 404, userInfo: [NSLocalizedDescriptionKey: "JSON file not found"])
        }
        
        print("Found multilingual_words.json at: \(url.path)")
        
        // Read the file data
        let data = try Data(contentsOf: url)
        
        // Try to decode it
        let decoder = JSONDecoder()
        return try decoder.decode(MultilingualData.self, from: data)
    }
    
    // Helper function to organize word pairs by category
    private func organizeByCategory(_ pairs: [WordPair]) -> [String: [String: String]] {
        var result: [String: [String: String]] = [:]
        
        for pair in pairs {
            if result[pair.category] == nil {
                result[pair.category] = [:]
            }
            result[pair.category]?[pair.sourceWord] = pair.targetWord
        }
        
        return result
    }
    
    // Helper to get language pairs in a format compatible with previous tests
    private func getLanguagePairMap() throws -> [String: [String: [String: String]]] {
        let data = try loadMultilingualData()
        var result: [String: [String: [String: String]]] = [:]
        
        for language in data.languages {
            let pairKey = "\(language.source)-\(language.target)"
            result[pairKey] = organizeByCategory(language.pairs)
        }
        
        return result
    }
    
    // Test the structure of the multilingual_words.json file
    func testMultilingualWordsFileStructure() throws {
        // Load the data
        let data = try loadMultilingualData()
        
        // Verify we have languages
        XCTAssertFalse(data.languages.isEmpty, "Should have language data")
        
        // Check at least one language pair
        guard let firstLanguage = data.languages.first else {
            XCTFail("No language pairs found")
            return
        }
        
        // Basic structure validation
        XCTAssertFalse(firstLanguage.source.isEmpty, "Source language should not be empty")
        XCTAssertFalse(firstLanguage.target.isEmpty, "Target language should not be empty")
        XCTAssertFalse(firstLanguage.name.source.isEmpty, "Source language name should not be empty")
        XCTAssertFalse(firstLanguage.name.target.isEmpty, "Target language name should not be empty")
        
        // Check pairs
        XCTAssertFalse(firstLanguage.pairs.isEmpty, "Language should have word pairs")
        
        // Verify at least some categories exist
        let categoryCounts = Dictionary(grouping: firstLanguage.pairs, by: { $0.category }).count
        XCTAssertGreaterThanOrEqual(categoryCounts, 2, "Should have at least 2 categories")
    }
    
    // Test that basic language pairs are available
    func testLanguagePairsAvailability() throws {
        // Load the data
        let data = try loadMultilingualData()
        
        // Get available language codes
        let availablePairs = data.languages.map { "\($0.source)-\($0.target)" }
        
        // Check for English-Spanish (this should definitely exist)
        XCTAssertTrue(availablePairs.contains("en-es"), "English to Spanish should be available")
        
        // Print available languages for debugging
        print("Available language pairs: \(availablePairs.joined(separator: ", "))")
        
        // Verify each language pair has a reasonable number of words
        for language in data.languages {
            XCTAssertGreaterThanOrEqual(language.pairs.count, 10, 
                "Language pair \(language.source)-\(language.target) should have at least 10 word pairs")
        }
    }
    
    // Test categories and word counts
    func testCategoriesAndWordCounts() throws {
        // Load the data
        let data = try loadMultilingualData()
        
        // Test for at least one language (likely to be Spanish)
        guard let spanish = data.languages.first(where: { $0.target == "es" }) else {
            print("Spanish language not found, skipping detailed test")
            return
        }
        
        // Count words by category
        let categoryCounts = Dictionary(grouping: spanish.pairs, by: { $0.category })
        
        // Verify some common categories exist for Spanish
        let commonCategories = ["verb", "food", "travel", "greeting", "common", "family"]
        var foundCategories = 0
        
        for category in commonCategories {
            if categoryCounts.keys.contains(where: { $0.lowercased() == category.lowercased() }) {
                foundCategories += 1
            }
        }
        
        // At least some of these categories should exist
        XCTAssertGreaterThanOrEqual(foundCategories, 2, "Spanish should have at least 2 common categories")
        
        // Verify at least one category has a reasonable number of words
        for (category, words) in categoryCounts {
            XCTAssertGreaterThanOrEqual(words.count, 5, "Category \(category) should have at least 5 words")
        }
    }
    
    // Test for specific common words in the Spanish language
    func testCommonWords() throws {
        // Load the data
        let data = try loadMultilingualData()
        
        // Test Spanish common words
        guard let spanish = data.languages.first(where: { $0.target == "es" }) else {
            print("Spanish language not found, skipping word test")
            return
        }
        
        // Find some common Spanish words
        let commonWords = ["hello", "goodbye", "please", "thank you", "yes", "no"]
        var foundWords = 0
        
        for word in commonWords {
            if spanish.pairs.contains(where: { $0.sourceWord.lowercased() == word }) {
                foundWords += 1
            }
        }
        
        // At least a few common words should exist
        XCTAssertGreaterThanOrEqual(foundWords, 1, "Should find at least one common greeting word in Spanish")
    }
} 