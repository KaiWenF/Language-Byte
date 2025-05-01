//
//  LanguagePair.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import Foundation

/// Represents a pair of languages (source and target) and their vocabulary
struct LanguagePair: Codable, Equatable, Hashable {
    let sourceLanguage: Language
    let targetLanguage: Language
    let pairs: [WordPair]
    
    // Unique identifier for Hashable conformance
    var id: String {
        return "\(sourceLanguage.code)-\(targetLanguage.code)"
    }
    
    // Required for Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Required for Equatable conformance
    static func == (lhs: LanguagePair, rhs: LanguagePair) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Represents a language with its code and name
struct Language: Codable, Equatable, Hashable {
    let code: String      // ISO language code (e.g., "en", "es", "fr")
    let name: String      // Display name (e.g., "English", "Spanish", "French")
    let speechCode: String // Speech synthesis language code (e.g., "en-US", "es-ES")
    
    // Common language presets
    static let english = Language(code: "en", name: "English", speechCode: "en-US")
    static let spanish = Language(code: "es", name: "Spanish", speechCode: "es-ES")
    static let french = Language(code: "fr", name: "French", speechCode: "fr-FR")
    static let german = Language(code: "de", name: "German", speechCode: "de-DE")
    static let italian = Language(code: "it", name: "Italian", speechCode: "it-IT")
    static let japanese = Language(code: "ja", name: "Japanese", speechCode: "ja-JP")
    static let chinese = Language(code: "zh", name: "Chinese", speechCode: "zh-CN")
    static let korean = Language(code: "ko", name: "Korean", speechCode: "ko-KR")
    static let haitianCreole = Language(code: "ht", name: "Haitian Creole", speechCode: "ht-HT")
    static let portuguese = Language(code: "pt", name: "Portuguese", speechCode: "pt-BR")
    
    // All supported languages
    static let allLanguages: [Language] = [
        .english, .spanish, .french, .german, .italian, .japanese, .chinese, .korean, .haitianCreole, .portuguese
    ]
} 