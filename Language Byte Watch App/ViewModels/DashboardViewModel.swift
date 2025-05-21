import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var weeklyProgress: [Int] = Array(repeating: 0, count: 7)
    @Published var totalWordsLearned: Int = 0
    @Published var currentStreak: Int = 0
    
    init() {
        calculateWeeklyProgress()
        calculateTotalWordsLearned()
        calculateCurrentStreak()
    }
    
    func calculateWeeklyProgress() -> [Int] {
        var progress: [Int] = Array(repeating: 0, count: 7)
        
        // Get the current date
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Calculate the date for the last 7 days
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: currentDate) {
                let dateString = formatDate(date)
                let key = "day_\(dateString)_words"
                let wordsCount = UserDefaults.standard.integer(forKey: key)
                
                // Store the count for this day
                progress[6 - i] = wordsCount
            }
        }
        
        weeklyProgress = progress
        return progress
    }
    
    func calculateTotalWordsLearned() -> Int {
        // Get the user's total words learned
        let total = UserDefaults.standard.integer(forKey: "total_words_learned")
        totalWordsLearned = total
        return total
    }
    
    func calculateCurrentStreak() -> Int {
        // Get the current date
        let currentDate = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Check if there's a record for today
        let todayString = dateFormatter.string(from: currentDate)
        let todayKey = "day_\(todayString)_words"
        let todayWords = UserDefaults.standard.integer(forKey: todayKey)
        
        var streak = 0
        var daysBack = 0
        
        // If user has studied today, start streak at 1
        if todayWords > 0 {
            streak = 1
            daysBack = 1
        }
        
        // Check previous days
        while true {
            // Get date for daysBack days ago
            guard let previousDate = calendar.date(byAdding: .day, value: -daysBack, to: currentDate) else {
                break
            }
            
            let dateString = dateFormatter.string(from: previousDate)
            let key = "day_\(dateString)_words"
            let words = UserDefaults.standard.integer(forKey: key)
            
            // If they studied on this day, increment streak
            if words > 0 {
                if streak > 0 { // Only increment if already on a streak
                    streak += 1
                } else {
                    streak = 1 // Start streak if today had no words
                }
                daysBack += 1
            } else {
                break // Break streak when a day is missed
            }
        }
        
        currentStreak = streak
        return streak
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
} 