import SwiftUI

struct QuizEnhancementsView: View {
    @StateObject private var viewModel = QuizEnhancementsViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.quizEnhancements) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .quizEnhancements)
        }
    }
    
    private var content: some View {
        List {
            Section(header: Text("Quiz Settings")) {
                Toggle("Show Timer", isOn: $viewModel.showTimer)
                Toggle("Track Streaks", isOn: $viewModel.trackStreaks)
                Toggle("Show Accuracy", isOn: $viewModel.showAccuracy)
            }
            
            Section(header: Text("Performance Tracking")) {
                HStack {
                    Text("Current Streak")
                    Spacer()
                    Text("\(viewModel.currentStreak) days")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Best Streak")
                    Spacer()
                    Text("\(viewModel.bestStreak) days")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Average Accuracy")
                    Spacer()
                    Text("\(Int(viewModel.averageAccuracy * 100))%")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Average Time")
                    Spacer()
                    Text(viewModel.averageTime)
                        .foregroundColor(.secondary)
                }
            }
            
            Section(header: Text("Recent Performance")) {
                ForEach(viewModel.recentQuizzes) { quiz in
                    QuizPerformanceRow(quiz: quiz)
                }
            }
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Quiz Enhancements")
                .font(.title2)
                .bold()
            
            Text("Unlock premium to track your progress with detailed statistics and performance insights")
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

struct QuizPerformanceRow: View {
    let quiz: QuizPerformance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quiz.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(quiz.accuracy * 100))%")
                    .font(.headline)
                    .foregroundColor(quiz.accuracy >= 0.8 ? .green : .orange)
            }
            
            HStack {
                Text("\(quiz.correctAnswers)/\(quiz.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(quiz.averageTime)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

class QuizEnhancementsViewModel: ObservableObject {
    @Published var showTimer = true
    @Published var trackStreaks = true
    @Published var showAccuracy = true
    
    @Published var currentStreak = 5
    @Published var bestStreak = 12
    @Published var averageAccuracy = 0.85
    @Published var averageTime = "1.5s"
    
    @Published var recentQuizzes: [QuizPerformance] = [
        QuizPerformance(
            id: "1",
            date: Date(),
            correctAnswers: 8,
            totalQuestions: 10,
            accuracy: 0.8,
            averageTime: "1.2s"
        ),
        QuizPerformance(
            id: "2",
            date: Date().addingTimeInterval(-86400),
            correctAnswers: 9,
            totalQuestions: 10,
            accuracy: 0.9,
            averageTime: "1.4s"
        )
    ]
}

struct QuizPerformance: Identifiable {
    let id: String
    let date: Date
    let correctAnswers: Int
    let totalQuestions: Int
    let accuracy: Double
    let averageTime: String
}

#Preview {
    QuizEnhancementsView()
} 