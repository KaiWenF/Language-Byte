import SwiftUI
import AVFoundation

// Basic scrolling text modifier for long words
struct SimpleScrollingModifier: ViewModifier {
    let text: String
    let speed: Double
    
    @State private var animating = false
    @State private var animationID = UUID()
    
    func body(content: Content) -> some View {
        // Create a container for the scrolling text
        // that extends beyond the screen bounds to ensure the full text is rendered
        ZStack(alignment: .leading) {
            content
                // Start from right edge (80), move to far left (-600)
                // Using a shorter distance to make the word return faster
                .offset(x: animating ? -300 : 80)
                .onAppear {
                    startAnimation()
                }
        }
        // Don't use .clipped() at all to prevent truncation
    }
    
    private func startAnimation() {
        // Initial very short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let currentID = animationID
            
            // Shorter duration for faster cycling
            // Adjust base duration based on speed
            let baseDuration = 800 / max(speed, 1)
            
            withAnimation(.linear(duration: baseDuration)) {
                animating = true
            }
            
            // Schedule word to reappear quickly after it scrolls off
            // This creates a faster cycle without changing the scrolling speed
            DispatchQueue.main.asyncAfter(deadline: .now() + baseDuration + 0.5) {
                // Only proceed if the animation hasn't been restarted
                guard currentID == animationID else { return }
                
                // Reset quickly without animation
                withAnimation(.none) {
                    animating = false
                }
                
                // Then start the next cycle
                startAnimation()
            }
        }
    }
}

// This is just a declaration - Xcode will find the actual class
// in the project structure, even if the linter shows an error
struct WordStudyView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Word display - automatic scrolling for long text
                    Group {
                        if viewModel.displayWord.count > 10 {
                            // Long text with scrolling - no container width limitation
                            ZStack(alignment: .leading) {
                                // This allows the text to have plenty of room to render
                                // without being constrained by screen edges
                                HStack(spacing: 0) {
                                    Text(viewModel.displayWord)
                                        .font(.largeTitle)
                                        .fixedSize(horizontal: true, vertical: false) // Ensure the text has its natural width
                                        .modifier(SimpleScrollingModifier(
                                            text: viewModel.displayWord,
                                            speed: determineScrollSpeed(for: viewModel.displayWord)
                                        ))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .frame(height: 60) // Give more vertical space
                        } else {
                            // Short text centered
                            Text(viewModel.displayWord)
                                .font(.largeTitle)
                                // Keep lineLimit for shorter texts to ensure they fit
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .padding(.horizontal, 5) // Reduce horizontal padding to maximize width
                    .padding(.top, 20)
                    
                    // Action buttons
                    Button(action: {
                        viewModel.pickRandomWord()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("New Word")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        viewModel.toggleDisplay()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left.arrow.right")
                            Text("Toggle Word")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        viewModel.speakCurrentWord()
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Speak Word")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        HStack {
                            Image(systemName: viewModel.isCurrentWordFavorite ? "star.fill" : "star")
                            Text("Favorite")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(viewModel.isCurrentWordFavorite ? .yellow : .blue)
                }
                .padding()
            }
            .navigationTitle("Word Study")
        }
    }
    
    // Helper function to adjust scroll speed based on text length
    private func determineScrollSpeed(for text: String) -> Double {
        let characterCount = text.count
        
        if characterCount <= 10 {
            return 70 // Short text: faster speed
        } else if characterCount <= 20 {
            return 60 // Medium text: medium speed
        } else {
            return 50 // Long phrases: slower for readability
        }
    }
}

// Preview provider
struct WordStudyView_Previews: PreviewProvider {
    static var previews: some View {
        WordStudyView()
            .environmentObject(WordViewModel())
    }
} 
