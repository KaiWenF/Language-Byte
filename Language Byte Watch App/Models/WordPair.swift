import Foundation

/// A word pair representing a translation between two languages
struct WordPair: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let sourceWord: String
    let targetWord: String
    let category: String
    let lastAttempted: Date?
    
    // Additional properties for quiz functionality
    var isCorrect: Bool?
    var timeSpent: TimeInterval?
    var difficulty: Int = 1
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, sourceWord, targetWord, category, lastAttempted
        case isCorrect, timeSpent, difficulty
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: WordPair, rhs: WordPair) -> Bool {
        lhs.id == rhs.id
    }
} 