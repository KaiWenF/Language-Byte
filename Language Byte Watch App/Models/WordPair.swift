//
//  WordPair.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen ] on [2/10/2025].
//

import Foundation


/// Represents a single word pair in your data, including its category.
struct WordPair: Codable, Equatable, Hashable {
    let foreignWord: String
    let translation: String
    let category: String
    
    // New CodingKeys to support both old and new JSON formats
    enum CodingKeys: String, CodingKey {
        case foreignWord = "targetWord"
        case translation = "sourceWord" 
        case category
        
        // For the new format
        case word
    }
    
    // Custom initializer to support both formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Try new format first (word/translation)
        if container.contains(.word) {
            let word = try container.decode(String.self, forKey: .word)
            self.translation = word
            self.foreignWord = try container.decode(String.self, forKey: .translation)
        } else {
            // Fall back to old format (sourceWord/targetWord)
            self.translation = try container.decode(String.self, forKey: .translation)
            self.foreignWord = try container.decode(String.self, forKey: .foreignWord)
        }
        
        self.category = try container.decode(String.self, forKey: .category)
    }
    
    // Encode method to complete Codable conformance
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(foreignWord, forKey: .foreignWord)
        try container.encode(translation, forKey: .translation)
        try container.encode(category, forKey: .category)
    }
    
    // Regular initializer
    init(foreignWord: String, translation: String, category: String) {
        self.foreignWord = foreignWord
        self.translation = translation
        self.category = category
    }
}
