import SwiftUI

struct WeeklyReviewView: View {
    @StateObject private var viewModel = WeeklyReviewViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.weeklyReview) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .weeklyReview)
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Weekly Review")
                    .font(.title2)
                    .bold()
                
                Text("Review your most challenging words from this week")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Stats Overview
                StatsOverviewView(stats: viewModel.weeklyStats)
                
                // Word List
                ForEach(viewModel.challengingWords) { word in
                    WordReviewCard(word: word)
                }
                
                // Start Quiz Button
                Button("Start Review Quiz") {
                    viewModel.startQuiz()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isQuizInProgress)
            }
            .padding()
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Weekly Review")
                .font(.title2)
                .bold()
            
            Text("Unlock premium to access weekly review quizzes and track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Upgrade to Premium") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct StatsOverviewView: View {
    let stats: WeeklyStats
    
    var body: some View {
        VStack(spacing: 10) {
            Text("This Week's Progress")
                .font(.headline)
            
            HStack(spacing: 20) {
                WeeklyStatItem(title: "Words", value: "\(stats.totalWords)")
                WeeklyStatItem(title: "Accuracy", value: "\(Int(stats.accuracy * 100))%")
                WeeklyStatItem(title: "Time", value: stats.averageTime)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct WeeklyStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct WordReviewCard: View {
    let word: WordPair
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(word.sourceWord)
                .font(.headline)
            
            Text(word.targetWord)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "clock")
                    .font(.caption)
                Text("Last attempted: \(word.lastAttempted?.formatted() ?? "Never")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    WeeklyReviewView()
} 