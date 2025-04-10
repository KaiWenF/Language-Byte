//
//  WordDataManager.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen ] on [2/10/2025].
//

import Foundation

/// Manages loading and returning a list of word pairs.
class WordDataManager {
    
    
    func loadWordsFromJSON() -> [WordPair] {
        guard let url = Bundle.main.url(forResource: "words", withExtension: "json") else {
            print("Could not find words.json in the bundle.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let wordPairs = try JSONDecoder().decode([WordPair].self, from: data)
            print("Successfully loaded \(wordPairs.count) words from JSON.")
            return wordPairs
        } catch {
            print("Error loading or decoding JSON: \(error)")
            return []
        }
    }
    
    
}


   

