//
//  LanguageDataManager.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import Foundation

/// Manages loading and organizing language pair data
class LanguageDataManager {
    
    // MARK: - Properties
    
    /// All available language pairs loaded from JSON
    private(set) var languagePairs: [LanguagePair] = []
    
    // MARK: - Initialization
    
    init() {
        // Load initial data when manager is created
        loadLanguageData()
    }
    
    // MARK: - Data Loading Methods
    
    /// Loads language data from JSON
    func loadLanguageData() {
        // First try to load the multi-language JSON file
        if let pairs = loadMultiLanguageData() {
            self.languagePairs = pairs
            return
        }
        
        // Fallback: Convert legacy words.json to a language pair
        if let legacyWords = loadLegacyWordsJSON() {
            // Create a Spanish-English language pair from legacy data
            let spanishEnglish = LanguagePair(
                sourceLanguage: Language.english,
                targetLanguage: Language.spanish,
                pairs: legacyWords
            )
            self.languagePairs = [spanishEnglish]
        }
    }
    
    /// Loads legacy words.json format (English-Spanish only)
    private func loadLegacyWordsJSON() -> [WordPair]? {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            print("⚠️ Could not find words.json in the bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let wordPairs = try JSONDecoder().decode([WordPair].self, from: data)
            print("📚 Successfully loaded \(wordPairs.count) words from legacy JSON.")
            return wordPairs
        } catch {
            print("❌ Error loading or decoding legacy JSON: \(error)")
            return nil
        }
    }
    
    /// Loads the new multi-language format
    private func loadMultiLanguageData() -> [LanguagePair]? {
        guard let url = Bundle.main.url(forResource: "language_data", withExtension: "json") else {
            print("⚠️ Could not find language_data.json in the bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let languagePairs = try JSONDecoder().decode([LanguagePair].self, from: data)
            print("🌍 Successfully loaded \(languagePairs.count) language pairs from JSON.")
            return languagePairs
        } catch {
            print("❌ Error loading or decoding language data JSON: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns a specific language pair based on source and target language codes
    func getLanguagePair(source: String, target: String) -> LanguagePair? {
        return languagePairs.first { 
            $0.sourceLanguage.code == source && $0.targetLanguage.code == target 
        }
    }
    
    /// Returns all available language pairs as displayable strings
    func getAvailableLanguagePairsDisplay() -> [String] {
        return languagePairs.map { 
            "\($0.sourceLanguage.name) → \($0.targetLanguage.name)" 
        }
    }
    
    /// Gets an index from a display string
    func getLanguagePairIndex(from displayString: String) -> Int? {
        let displayStrings = getAvailableLanguagePairsDisplay()
        return displayStrings.firstIndex(of: displayString)
    }
} 