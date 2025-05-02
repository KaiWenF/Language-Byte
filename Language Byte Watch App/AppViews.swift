import SwiftUI

// MARK: - Content View
struct ContentView: View {
    // Use direct state instead of environment
    @State private var totalXP: Int = UserDefaults.standard.integer(forKey: "xp_total")
    @State private var userLevel: Int = UserDefaults.standard.integer(forKey: "user_level")
    @State private var xpProgress: Double = 0.0
    
    // Constants
    private let xpPerLevel = 100
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Language Byte")
                    .font(.title)
                
                // XP display
                VStack(spacing: 8) {
                    Text("Level \(userLevel)")
                        .font(.headline)
                    
                    ProgressView(
                        value: xpProgress,
                        total: 1.0
                    )
                    .tint(.blue)
                    
                    Text("\(totalXP) XP")
                        .font(.caption)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue.opacity(0.1)))
                
                // Test XP button
                Button("Add XP") {
                    addXP(10)
                }
                .buttonStyle(.borderedProminent)
                
                // Link to Level view
                NavigationLink {
                    if #available(watchOS 9.0, *) {
                        LevelViewDetail()
                    } else {
                        LevelViewLegacy()
                    }
                } label: {
                    Text("View Level Details")
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding()
            .onAppear {
                refreshXPValues()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("com.languagebyte.xpUpdated"))) { _ in
                refreshXPValues()
            }
        }
    }
    
    // Helper to refresh XP values
    private func refreshXPValues() {
        totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        userLevel = UserDefaults.standard.integer(forKey: "user_level")
        
        // Calculate progress
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = totalXP - currentLevelXP
        xpProgress = Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    // Add XP and update UserDefaults
    private func addXP(_ amount: Int) {
        totalXP += amount
        let newLevel = 1 + (totalXP / xpPerLevel)
        let didLevelUp = newLevel > userLevel
        userLevel = newLevel
        
        // Calculate new progress
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = totalXP - currentLevelXP
        xpProgress = Double(xpInCurrentLevel) / Double(xpPerLevel)
        
        // Save to UserDefaults
        UserDefaults.standard.set(totalXP, forKey: "xp_total")
        UserDefaults.standard.set(userLevel, forKey: "user_level")
        
        // Post notifications
        if didLevelUp {
            NotificationCenter.default.post(
                name: Notification.Name("com.languagebyte.levelUp"),
                object: nil,
                userInfo: ["newLevel": userLevel]
            )
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("com.languagebyte.xpUpdated"),
            object: nil,
            userInfo: ["amount": amount, "total": totalXP]
        )
    }
}

// MARK: - Level View
struct LevelViewLegacy: View {
    // Use direct state variables
    @State private var totalXP: Int = 0
    @State private var userLevel: Int = 0
    @State private var xpProgress: Double = 0.0
    @State private var showLevelUpAnimation: Bool = false
    @State private var showConfetti: Bool = false
    
    // Constants
    private let xpPerLevel = 100
    
    var body: some View {
        ZStack {
            // Main content
            ScrollView {
                VStack(spacing: 20) {
                    // Level badge with animation
                    ZStack {
                        // Background circle
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        // Progress ring
                        Circle()
                            .trim(from: 0, to: xpProgress)
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(lineWidth: 10, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut, value: xpProgress)
                        
                        // Level number
                        VStack {
                            Text("\(userLevel)")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Level")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        // Level up glow animation
                        if showLevelUpAnimation {
                            Circle()
                                .fill(Color.yellow.opacity(0.5))
                                .frame(width: 140, height: 140)
                                .blur(radius: 10)
                                .transition(.opacity)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Level title
                    Text(getLevelTitle())
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                    
                    Divider()
                        .padding(.vertical, 10)
                    
                    // XP Statistics
                    VStack(spacing: 12) {
                        HStack {
                            Text("Total XP:")
                            Spacer()
                            Text("\(totalXP) XP")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("XP to Next Level:")
                            Spacer()
                            Text("\(getXPtoNextLevel()) XP")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("Progress:")
                            Spacer()
                            Text("\(Int(xpProgress * 100))%")
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    // XP History Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Achievements")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        AchievementRow(icon: "checkmark.circle.fill", title: "Answer Streak", xp: "+20 XP")
                        AchievementRow(icon: "flame.fill", title: "Daily Challenge", xp: "+50 XP")
                        AchievementRow(icon: "star.fill", title: "Perfect Score", xp: "+100 XP")
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                    
                    // Test button to simulate level up (DEBUG only)
                    #if DEBUG
                    Button("Simulate Level Up") {
                        simulateLevelUp()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 20)
                    #endif
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("My Level")
            .onAppear {
                refreshXPValues()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("com.languagebyte.xpUpdated"))) { _ in
                refreshXPValues()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("com.languagebyte.levelUp"))) { _ in
                triggerLevelUpAnimation()
            }
            
            // Confetti effect overlay
            if showConfetti {
                ZStack {
                    ForEach(0..<30, id: \.self) { _ in
                        ConfettiParticleLegacy(color: .blue)
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .transition(.opacity)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Refresh XP values from UserDefaults
    private func refreshXPValues() {
        totalXP = UserDefaults.standard.integer(forKey: "xp_total")
        userLevel = UserDefaults.standard.integer(forKey: "user_level")
        calculateProgress()
    }
    
    /// Calculate level progress (0.0 to 1.0)
    private func calculateProgress() {
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = totalXP - currentLevelXP
        xpProgress = Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    /// Calculate XP needed for next level
    private func getXPtoNextLevel() -> Int {
        let nextLevelThreshold = userLevel * xpPerLevel
        return max(nextLevelThreshold - totalXP, 0)
    }
    
    /// Get level title based on current level
    private func getLevelTitle() -> String {
        switch userLevel {
        case 1:
            return "Novice Learner"
        case 2:
            return "Word Explorer"
        case 3:
            return "Language Enthusiast"
        case 4:
            return "Vocabulary Builder"
        case 5:
            return "Fluency Seeker"
        case 6...7:
            return "Language Adept"
        case 8...9:
            return "Linguistic Master"
        case 10...14:
            return "Polyglot Virtuoso"
        case 15...19:
            return "Language Sage"
        case _ where userLevel >= 20:
            return "Grand Language Master"
        default:
            return "Language Student"
        }
    }
    
    /// Trigger the level up animation
    private func triggerLevelUpAnimation() {
        // Show the animation
        withAnimation(.easeInOut(duration: 0.5)) {
            showLevelUpAnimation = true
            showConfetti = true
        }
        
        // Hide after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showLevelUpAnimation = false
            }
        }
        
        // Hide confetti after slightly longer
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showConfetti = false
            }
        }
    }
    
    // DEBUG: Simulate a level up for testing
    private func simulateLevelUp() {
        // Calculate needed XP for level up
        let currentXP = UserDefaults.standard.integer(forKey: "xp_total")
        let currentLevel = UserDefaults.standard.integer(forKey: "user_level")
        let xpNeeded = (currentLevel * xpPerLevel) - currentXP + 1
        
        // Add the XP
        addXP(xpNeeded)
    }
    
    /// Add XP and update UserDefaults
    private func addXP(_ amount: Int) {
        // Get current values
        let currentXP = UserDefaults.standard.integer(forKey: "xp_total")
        let currentLevel = UserDefaults.standard.integer(forKey: "user_level")
        
        // Calculate new values
        let newXP = currentXP + amount
        let newLevel = 1 + (newXP / xpPerLevel)
        
        // Save to UserDefaults
        UserDefaults.standard.set(newXP, forKey: "xp_total")
        UserDefaults.standard.set(newLevel, forKey: "user_level")
        
        // Update local state
        totalXP = newXP
        userLevel = newLevel
        calculateProgress()
        
        // Post notifications
        if newLevel > currentLevel {
            NotificationCenter.default.post(
                name: Notification.Name("com.languagebyte.levelUp"),
                object: nil,
                userInfo: ["newLevel": newLevel]
            )
        }
        
        NotificationCenter.default.post(
            name: Notification.Name("com.languagebyte.xpUpdated"),
            object: nil,
            userInfo: ["amount": amount, "total": newXP]
        )
    }
}

// MARK: - Helper Views

// Helper view for achievement rows
struct AchievementRow: View {
    let icon: String
    let title: String
    let xp: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.system(size: 16))
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(xp)
                .font(.subheadline)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// Particle view for confetti effect
struct ConfettiParticleLegacy: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var rotation = Double.random(in: 0...360)
    @State private var scale = Double.random(in: 0.5...1.5)
    @State private var opacity = 1.0
    
    let color: Color
    let size: CGFloat
    
    init(color: Color) {
        self.color = color
        self.size = CGFloat.random(in: 5...15)
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: size, height: size)
            .rotationEffect(.degrees(rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .position(position)
            .onAppear {
                // Random starting position at the bottom center
                let randomX = Double.random(in: 50...200)
                position = CGPoint(x: randomX, y: 150)
                
                // Animate upward with random horizontal movement
                withAnimation(.easeOut(duration: Double.random(in: 1.0...2.0))) {
                    let posX = position.x
                    let minX = max(0, posX - 30.0)
                    let maxX = min(250, posX + 30.0)
                    let randomX = Double.random(in: minX...maxX)
                    
                    position = CGPoint(x: randomX, y: -20.0)
                    opacity = 0
                    scale *= Double.random(in: 0.5...1.5)
                    rotation += Double.random(in: 180...720)
                }
            }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct LevelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            if #available(watchOS 9.0, *) {
                LevelViewDetail()
            } else {
                LevelViewLegacy()
            }
        }
    }
} 