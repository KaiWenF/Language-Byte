import SwiftUI
#if os(watchOS)
import WatchKit
#endif
import Foundation

// MARK: - ConfettiParticle View
struct ConfettiParticle: View {
    @State private var position = CGPoint(x: 0, y: 0)
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    @State private var scale: Double = 0.1
    
    let color: Color
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .onAppear {
                // Random initial position at the top of the screen
                #if os(watchOS)
                let screenWidth = WKInterfaceDevice.current().screenBounds.width
                #else
                let screenWidth: CGFloat = 300 // Default fallback value for simulator
                #endif
                
                position = CGPoint(
                    x: .random(in: 0...screenWidth),
                    y: -20
                )
                
                // Animate falling with random values
                withAnimation(.timingCurve(0.1, 0.8, 0.5, 1, duration: .random(in: 1.5...3.5))) {
                    opacity = .random(in: 0.6...1.0)
                    scale = .random(in: 0.8...1.2)
                    
                    #if os(watchOS)
                    position.y = WKInterfaceDevice.current().screenBounds.height + 20
                    #else
                    position.y = 300 // Default fallback value for simulator
                    #endif
                    
                    rotation = .random(in: 180...360) * (.random(in: 0...1) > 0.5 ? 1 : -1)
                }
                
                // Fade out near the end of the animation
                withAnimation(.easeOut(duration: .random(in: 0.8...1.2)).delay(.random(in: 2.0...3.0))) {
                    opacity = 0
                }
            }
    }
}

// MARK: - Confetti View
struct LevelConfettiView: View {
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let particleCount = 50
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { i in
                ConfettiParticle(color: colors[i % colors.count])
            }
        }
    }
}

// MARK: - Alternative LevelView 
// Use UserDefaults directly to avoid dependency issues
@available(watchOS 9.0, *)
struct LevelViewDetail: View {
    // State for XP and level
    @AppStorage("xp_total") private var xpTotal: Int = 0
    @AppStorage("user_level") private var userLevel: Int = 1
    
    // Constants
    private let xpPerLevel: Int = 100
    
    // Notification names
    private let levelUpNotification = Notification.Name("com.languagebyte.levelUp")
    
    // Animation states
    @State private var showLevelUpAnimation = false
    @State private var showConfetti = false
    @State private var rotationAmount: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Level circle with progress ring
                ZStack {
                    // Outer glow when leveling up
                    if showLevelUpAnimation {
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.yellow.opacity(0.5), Color.yellow.opacity(0)]),
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 90
                                )
                            )
                            .frame(width: 170, height: 170)
                            .scaleEffect(showLevelUpAnimation ? 1.1 : 1.0)
                    }
                    
                    // Background circle
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 150, height: 150)
                        .shadow(color: showLevelUpAnimation ? .yellow.opacity(0.5) : .clear, radius: 5)
                    
                    // Progress ring
                    Circle()
                        .trim(from: 0, to: getLevelProgress())
                        .stroke(
                            Color.blue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: getLevelProgress())
                    
                    // Inner content
                    VStack(spacing: 4) {
                        Text("\(userLevel)")
                            .font(.system(size: 46, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("LEVEL")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                    .rotationEffect(.degrees(rotationAmount))
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showLevelUpAnimation)
                }
                .padding(.top, 20)
                
                // Level title with icon
                HStack {
                    Image(systemName: getLevelIcon())
                        .font(.system(size: 18))
                        .foregroundColor(.blue)
                    
                    Text(getLevelTitle())
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                )
                
                Divider()
                    .padding(.vertical, 10)
                
                // XP Stats Section
                VStack(spacing: 16) {
                    // Total XP
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        
                        Text("Total XP")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(xpTotal)")
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    // XP to Next Level
                    HStack {
                        Image(systemName: "arrow.up.forward")
                            .foregroundColor(.green)
                        
                        Text("Next Level")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(xpToNextLevel()) XP needed")
                            .bold()
                            .foregroundColor(.primary)
                    }
                    
                    // Progress percentage
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                        
                        Text("Progress")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int(getLevelProgress() * 100))%")
                            .bold()
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.1))
                )
                
                // Test Level-Up button visible only in preview/debug mode
                #if DEBUG
                Button("Simulate Level Up") {
                    simulateLevelUp()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                #endif
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("My Level")
        .onReceive(NotificationCenter.default.publisher(for: levelUpNotification)) { _ in
            // Trigger level up animation
            withAnimation {
                showLevelUpAnimation = true
                showConfetti = true
                rotationAmount = 360
            }
            
            // Schedule reset of animations
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showLevelUpAnimation = false
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation {
                    showConfetti = false
                }
                rotationAmount = 0
            }
        }
        .overlay(
            ZStack {
                // Confetti overlay
                if showConfetti {
                    LevelConfettiView()
                        .allowsHitTesting(false)
                }
            }
        )
    }
    
    // Simulate a level up for preview/testing
    private func simulateLevelUp() {
        let currentLevel = userLevel
        let xpNeeded = (currentLevel * 100) - xpTotal + 1
        addXP(xpNeeded)
    }
    
    // Add XP to user's total
    private func addXP(_ amount: Int) {
        // Store current level for comparison
        let oldLevel = userLevel
        
        // Add XP to total
        xpTotal += amount
        
        // Recalculate level (1 + XP/100)
        userLevel = 1 + (xpTotal / xpPerLevel)
        
        // Post notification for XP update
        NotificationCenter.default.post(
            name: Notification.Name("com.languagebyte.xpUpdated"),
            object: nil,
            userInfo: ["amount": amount, "total": xpTotal]
        )
        
        // Check for level-up
        if userLevel > oldLevel {
            // Play haptic feedback for level-up on watchOS
            #if os(watchOS)
            WKInterfaceDevice.current().play(.success)
            #endif
            
            // Post level-up notification
            NotificationCenter.default.post(
                name: levelUpNotification,
                object: nil,
                userInfo: ["newLevel": userLevel]
            )
        }
    }
    
    // Calculate XP needed to reach next level
    private func xpToNextLevel() -> Int {
        let nextLevelThreshold = userLevel * xpPerLevel
        return max(nextLevelThreshold - xpTotal, 0)
    }
    
    // Get progress percentage towards next level (0.0 to 1.0)
    private func getLevelProgress() -> Double {
        let currentLevelXP = (userLevel - 1) * xpPerLevel
        let xpInCurrentLevel = xpTotal - currentLevelXP
        return Double(xpInCurrentLevel) / Double(xpPerLevel)
    }
    
    // Choose an icon based on the current level
    private func getLevelIcon() -> String {
        switch userLevel {
        case 1...3:
            return "leaf.fill"
        case 4...6:
            return "flame.fill"
        case 7...10:
            return "bolt.fill"
        case 11...15:
            return "star.fill"
        case 16...20:
            return "crown.fill"
        case _ where userLevel > 20:
            return "wand.and.stars"
        default:
            return "star.fill"
        }
    }
    
    // Get level title based on current level
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
}

// MARK: - Preview
#Preview {
    NavigationStack {
        if #available(watchOS 9.0, *) {
            LevelViewDetail()
        } else {
            Text("Requires watchOS 9.0 or newer")
        }
    }
} 