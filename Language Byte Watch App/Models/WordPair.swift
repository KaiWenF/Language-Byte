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
}
