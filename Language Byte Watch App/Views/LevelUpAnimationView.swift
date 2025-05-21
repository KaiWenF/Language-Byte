import SwiftUI

struct LevelUpAnimationView: View {
    @StateObject private var viewModel = LevelUpAnimationViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.levelUpAnimations) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .levelUpAnimations)
        }
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            // Level Display
            Text("Level \(viewModel.currentLevel)")
                .font(.largeTitle)
                .bold()
            
            // XP Progress
            VStack(spacing: 8) {
                ProgressView(value: viewModel.xpProgress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
                
                Text("\(viewModel.currentXP)/\(viewModel.nextLevelXP) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Level Up Button (for demo)
            Button("Simulate Level Up") {
                viewModel.simulateLevelUp()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .overlay {
            if viewModel.isAnimating {
                ConfettiView()
            }
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Level Up Animations")
                .font(.title2)
                .bold()
            
            Text("Unlock premium to enjoy special animations and celebrations when you level up")
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

struct ConfettiView: View {
    @State private var particles: [Particle] = []
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(particle.position)
            }
        }
        .onAppear {
            generateParticles()
        }
    }
    
    private func generateParticles() {
        particles = (0..<50).map { _ in
            Particle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...100),
                    y: CGFloat.random(in: 0...100)
                ),
                color: [
                    .blue,
                    .red,
                    .green,
                    .yellow,
                    .purple,
                    .orange
                ].randomElement()!,
                size: CGFloat.random(in: 4...8)
            )
        }
    }
}

struct Particle: Identifiable {
    let id = UUID()
    let position: CGPoint
    let color: Color
    let size: CGFloat
}

class LevelUpAnimationViewModel: ObservableObject {
    @Published var currentLevel = 5
    @Published var currentXP = 450
    @Published var nextLevelXP = 500
    @Published var isAnimating = false
    
    var xpProgress: Double {
        Double(currentXP) / Double(nextLevelXP)
    }
    
    func simulateLevelUp() {
        isAnimating = true
        
        // Simulate XP gain
        withAnimation(.easeInOut(duration: 1.0)) {
            currentXP = nextLevelXP
        }
        
        // Level up after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                self.currentLevel += 1
                self.currentXP = 0
                self.nextLevelXP = Int(Double(self.nextLevelXP) * 1.5)
            }
        }
        
        // Stop animation after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                self.isAnimating = false
            }
        }
    }
}

#Preview {
    LevelUpAnimationView()
} 