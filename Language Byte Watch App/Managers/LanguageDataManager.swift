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
        // Try to load from multilingual_words.json
        if let pairs = loadMultilingualWordsJSON() {
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
    
    /// Loads data from multilingual_words.json format
    private func loadMultilingualWordsJSON() -> [LanguagePair]? {
        guard let url = Bundle.main.url(forResource: "multilingual_words", withExtension: "json") else {
            print("⚠️ Could not find multilingual_words.json in the bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            
            // Define the structure for the multilingual words JSON
            struct MultilingualData: Codable {
                struct LanguageData: Codable {
                    let source: String
                    let target: String
                    let name: LanguageName
                    let pairs: [WordPairData]
                    
                    struct LanguageName: Codable {
                        let source: String
                        let target: String
                    }
                    
                    struct WordPairData: Codable {
                        let sourceWord: String
                        let targetWord: String
                        let category: String
                    }
                }
                
                let languages: [LanguageData]
            }
            
            // Decode the JSON
            let multilingualData = try JSONDecoder().decode(MultilingualData.self, from: data)
            
            // Convert to our LanguagePair model
            var languagePairs: [LanguagePair] = []
            
            for langData in multilingualData.languages {
                // Create Language objects
                let sourceLanguage = Language(
                    code: langData.source,
                    name: langData.name.source,
                    speechCode: getSpeechCode(for: langData.source)
                )
                
                let targetLanguage = Language(
                    code: langData.target,
                    name: langData.name.target,
                    speechCode: getSpeechCode(for: langData.target)
                )
                
                // Convert word pairs
                let wordPairs = langData.pairs.map { pair in
                    WordPair(
                        foreignWord: pair.targetWord,
                        translation: pair.sourceWord,
                        category: pair.category
                    )
                }
                
                // Create and add the language pair
                let languagePair = LanguagePair(
                    sourceLanguage: sourceLanguage,
                    targetLanguage: targetLanguage,
                    pairs: wordPairs
                )
                
                languagePairs.append(languagePair)
            }
            
            print("📚 Successfully loaded \(languagePairs.count) language pairs from multilingual JSON with \(languagePairs.flatMap { $0.pairs }.count) total words.")
            return languagePairs
        } catch {
            print("❌ Error loading or decoding multilingual JSON: \(error)")
            return nil
        }
    }
    
    /// Helper to get speech code from language code
    private func getSpeechCode(for languageCode: String) -> String {
        switch languageCode {
        case "en": return "en-US"
        case "es": return "es-ES"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "it": return "it-IT"
        case "ja": return "ja-JP"
        case "zh": return "zh-CN"
        default: return "\(languageCode)-\(languageCode.uppercased())"
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