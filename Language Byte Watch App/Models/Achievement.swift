import Foundation

/// Achievement model used throughout the app
struct Achievement: Identifiable {
    let id: String
    let title: String
    let description: String
    let unlocked: Bool
    let iconName: String  // SF Symbol name for the achievement
} 