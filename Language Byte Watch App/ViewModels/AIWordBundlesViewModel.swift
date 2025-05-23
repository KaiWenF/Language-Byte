import SwiftUI

public class AIWordBundlesViewModel: ObservableObject {
    @Published public var performanceInsights: [PerformanceInsight] = []
    @Published public var wordBundles: [WordBundle] = []
    @Published public var isGenerating = false
    
    public init() {
        loadData()
    }
    
    func loadData() {
        // TODO: Implement data loading from LanguageDataManager
        // For now, using mock data
        performanceInsights = [
            PerformanceInsight(
                id: "1",
                icon: "chart.bar.fill",
                description: "You're strongest in greetings and basic phrases"
            ),
            PerformanceInsight(
                id: "2",
                icon: "clock.fill",
                description: "You learn best in the morning"
            ),
            PerformanceInsight(
                id: "3",
                icon: "exclamationmark.triangle.fill",
                description: "Numbers and dates need more practice"
            )
        ]
        
        wordBundles = [
            WordBundle(
                id: "1",
                title: "Numbers Mastery",
                description: "Focus on improving your number recognition and pronunciation",
                words: [
                    WordPair(id: "1", sourceWord: "One", targetWord: "Uno", category: "Numbers", lastAttempted: nil),
                    WordPair(id: "2", sourceWord: "Two", targetWord: "Dos", category: "Numbers", lastAttempted: nil)
                ],
                tags: ["Numbers", "Beginner", "High Priority"]
            ),
            WordBundle(
                id: "2",
                title: "Daily Conversations",
                description: "Essential phrases for everyday interactions",
                words: [
                    WordPair(id: "3", sourceWord: "How are you?", targetWord: "¿Cómo estás?", category: "Phrases", lastAttempted: nil),
                    WordPair(id: "4", sourceWord: "Thank you", targetWord: "Gracias", category: "Phrases", lastAttempted: nil)
                ],
                tags: ["Phrases", "Intermediate", "Popular"]
            )
        ]
    }
    
    public func generateNewBundle() {
        isGenerating = true
        // TODO: Implement AI bundle generation
        // For now, just add a mock bundle
        let newBundle = WordBundle(
            id: UUID().uuidString,
            title: "New Bundle",
            description: "Generated based on your learning patterns",
            words: [
                WordPair(id: "5", sourceWord: "New", targetWord: "Nuevo", category: "Adjectives", lastAttempted: nil),
                WordPair(id: "6", sourceWord: "Bundle", targetWord: "Paquete", category: "Nouns", lastAttempted: nil)
            ],
            tags: ["AI Generated", "Personalized"]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.wordBundles.append(newBundle)
            self.isGenerating = false
        }
    }
    
    public func startPractice(with bundle: WordBundle) {
        // TODO: Implement practice session
    }
}

public struct PerformanceInsight: Identifiable {
    public let id: String
    public let icon: String
    public let description: String
    
    public init(id: String, icon: String, description: String) {
        self.id = id
        self.icon = icon
        self.description = description
    }
}

public struct WordBundle: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let words: [WordPair]
    public let tags: [String]
    
    public init(id: String, title: String, description: String, words: [WordPair], tags: [String]) {
        self.id = id
        self.title = title
        self.description = description
        self.words = words
        self.tags = tags
    }
} 