import Foundation

/// A word pair representing a translation between two languages
public struct WordPair: Identifiable, Codable, Equatable, Hashable {
    public let id: String
    public let sourceWord: String
    public let targetWord: String
    public let category: String
    public let lastAttempted: Date?
    
    // Additional properties for quiz functionality
    public var isCorrect: Bool?
    public var timeSpent: TimeInterval?
    public var difficulty: Int = 1
    
    public init(id: String, sourceWord: String, targetWord: String, category: String, lastAttempted: Date? = nil, isCorrect: Bool? = nil, timeSpent: TimeInterval? = nil, difficulty: Int = 1) {
        self.id = id
        self.sourceWord = sourceWord
        self.targetWord = targetWord
        self.category = category
        self.lastAttempted = lastAttempted
        self.isCorrect = isCorrect
        self.timeSpent = timeSpent
        self.difficulty = difficulty
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, sourceWord, targetWord, category, lastAttempted
        case isCorrect, timeSpent, difficulty
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: WordPair, rhs: WordPair) -> Bool {
        lhs.id == rhs.id
    }
} 