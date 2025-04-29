import SwiftUI
import AVFoundation

struct WordStudyView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Word display with marquee text
                    AdaptiveMarqueeText(
                        text: viewModel.displayWord,
                        font: .largeTitle,
                        speed: determineScrollSpeed(for: viewModel.displayWord)
                    )
                    .multilineTextAlignment(.center)
                    .frame(height: 40)
                    .padding(.horizontal, 10)
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
            return 25 // Short text: faster scroll
        } else if characterCount <= 20 {
            return 20 // Medium text: medium speed
        } else {
            return 15 // Long phrases: slower for readability
        }
    }
}

#Preview {
    WordStudyView()
        .environmentObject(WordViewModel())
} 