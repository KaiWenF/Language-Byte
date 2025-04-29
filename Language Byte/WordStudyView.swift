import SwiftUI
import AVFoundation

struct WordStudyView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Word display with marquee text
                AdaptiveMarqueeText(
                    text: viewModel.displayWord,
                    font: .system(size: 32, weight: .bold),
                    speed: 50,
                    delay: 1
                )
                .frame(height: 40)
                
                // Action buttons
                VStack(spacing: 20) {
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
                .padding(.horizontal)
            }
            .navigationTitle("Word Study")
        }
    }
}

#Preview {
    WordStudyView()
        .environmentObject(WordViewModel())
} 