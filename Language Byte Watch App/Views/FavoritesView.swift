import SwiftUI
import AVFoundation

struct FavoritesView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    private func speak(word: WordPair) {
        // Stop any ongoing speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: word.sourceWord)
        
        // Get the best available voice for the language
        if let voice = AVSpeechSynthesisVoice(language: viewModel.selectedLanguagePair?.targetLanguage.speechCode ?? "en-US") {
            utterance.voice = voice
        }
        
        // Adjust speech rate based on language
        let languageCode = viewModel.selectedLanguagePair?.targetLanguage.code ?? "en"
        switch languageCode {
        case "ja", "zh", "ko": // Asian languages typically need slower speech
            utterance.rate = 0.4
        case "es", "it", "fr": // Romance languages
            utterance.rate = 0.5
        default:
            utterance.rate = 0.5
        }
        
        // Set pitch and volume for natural sound
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(viewModel.favoriteWordPairs), id: \.sourceWord) { favorite in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(favorite.sourceWord) → \(favorite.targetWord)")
                                .font(.body)
                            
                            Text(viewModel.selectedLanguagePair?.targetLanguage.name ?? "Target Language")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            speak(word: favorite)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete { indexSet in
                    let wordsToDelete = indexSet.map { Array(viewModel.favoriteWordPairs)[$0] }
                    for word in wordsToDelete {
                        viewModel.favoriteWordPairs.remove(word)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(WordViewModel())
} 