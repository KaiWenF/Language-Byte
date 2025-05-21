import SwiftUI
import Foundation

class WeeklyReviewViewModel: ObservableObject {
    @Published var weeklyStats = WeeklyStats()
    @Published var challengingWords: [WordPair] = []
    @Published var isQuizInProgress = false
    
    init() {
        loadWeeklyData()
    }
    
    func loadWeeklyData() {
        // TODO: Implement data loading from LanguageDataManager
        // For now, using mock data
        weeklyStats = WeeklyStats(
            totalWords: 50,
            accuracy: 0.75,
            averageTime: "2.5s"
        )
        
        challengingWords = [
            WordPair(
                id: "1",
                sourceWord: "Hello",
                targetWord: "Hola",
                category: "Greetings",
                lastAttempted: Date().addingTimeInterval(-86400)
            ),
            WordPair(
                id: "2",
                sourceWord: "Goodbye",
                targetWord: "Adiós",
                category: "Greetings",
                lastAttempted: Date().addingTimeInterval(-172800)
            )
        ]
    }
    
    func startQuiz() {
        isQuizInProgress = true
        // TODO: Implement quiz logic
    }
}

struct WeeklyStats {
    var totalWords: Int = 0
    var accuracy: Double = 0.0
    var averageTime: String = "0s"
} 