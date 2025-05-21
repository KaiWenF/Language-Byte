import SwiftUI
import Foundation

// Local achievement struct with a different name to avoid conflicts with QuizStatsView
struct AchievementItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    var unlocked: Bool = false
}

struct AchievementsView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.achievements) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .achievements)
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress Overview
                ProgressOverviewView(progress: viewModel.overallProgress)
                
                // Achievement Categories
                ForEach(AchievementCategory.allCases, id: \.self) { category in
                    AchievementCategoryView(
                        category: category,
                        achievements: viewModel.achievements(for: category)
                    )
                }
            }
            .padding()
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Achievements")
                .font(.title2)
                .bold()
            
            Text("Unlock premium to access all achievements and track your progress")
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

struct ProgressOverviewView: View {
    let progress: AchievementProgress
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Overall Progress")
                .font(.headline)
            
            HStack(spacing: 20) {
                StatItem(title: "Unlocked", value: "\(progress.unlockedCount)")
                StatItem(title: "Total", value: "\(progress.totalCount)")
                StatItem(title: "Progress", value: "\(Int(progress.percentage * 100))%")
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AchievementCategoryView: View {
    let category: AchievementCategory
    let achievements: [AchievementViewItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(category.title)
                .font(.headline)
            
            ForEach(achievements) { achievement in
                AchievementRow(achievement: achievement)
            }
        }
    }
}

struct AchievementRow: View {
    let achievement: AchievementViewItem
    
    var body: some View {
        HStack {
            Image(systemName: achievement.isUnlocked ? achievement.icon : "lock.fill")
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? .yellow : .secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .bold()
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let progress = achievement.progress {
                    ProgressView(value: progress)
                        .tint(.blue)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

class AchievementsViewModel: ObservableObject {
    @Published var overallProgress = AchievementProgress(
        unlockedCount: 5,
        totalCount: 20,
        percentage: 0.25
    )
    
    @Published var achievements: [AchievementViewItem] = [
        AchievementViewItem(
            id: "1",
            title: "First Steps",
            description: "Complete your first quiz",
            icon: "star.fill",
            isUnlocked: true,
            progress: nil
        ),
        AchievementViewItem(
            id: "2",
            title: "Streak Master",
            description: "Maintain a 7-day streak",
            icon: "flame.fill",
            isUnlocked: false,
            progress: 0.6
        ),
        AchievementViewItem(
            id: "3",
            title: "Perfect Score",
            description: "Get 100% on a quiz",
            icon: "checkmark.circle.fill",
            isUnlocked: false,
            progress: nil
        )
    ]
    
    func achievements(for category: AchievementCategory) -> [AchievementViewItem] {
        // TODO: Implement filtering by category
        return achievements
    }
}

struct AchievementProgress {
    let unlockedCount: Int
    let totalCount: Int
    let percentage: Double
}

// Using custom Achievement for the view 
struct AchievementViewItem: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    let progress: Double?
}

enum AchievementCategory: CaseIterable {
    case learning
    case streaks
    case accuracy
    case special
    
    var title: String {
        switch self {
        case .learning: return "Learning"
        case .streaks: return "Streaks"
        case .accuracy: return "Accuracy"
        case .special: return "Special"
        }
    }
}

// StatItem component
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    AchievementsView()
} 