import SwiftUI
import AVFoundation

struct FavoritesView: View {
    @EnvironmentObject private var favoritesManager: FavoritesManager
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    
    private func speak(word: FavoriteWord) {
        // Stop any ongoing speech
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: word.targetWord)
        
        // Get the best available voice for the language
        if let voice = AVSpeechSynthesisVoice(language: word.targetLanguageCode) {
            utterance.voice = voice
        }
        
        // Adjust speech rate based on language
        switch word.targetLanguageCode {
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
    
    private func deleteFavorite(at offsets: IndexSet) {
        withAnimation {
            // Get the words to be deleted
            let wordsToDelete = offsets.map { favoritesManager.favoriteWords[$0] }
            
            // Remove from FavoritesManager
            for word in wordsToDelete {
                favoritesManager.removeFavorite(
                    sourceWord: word.sourceWord,
                    targetWord: word.targetWord
                )
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(favoritesManager.favoriteWords) { favorite in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(favorite.sourceWord) → \(favorite.targetWord)")
                                .font(.body)
                            
                            Text(Locale.current.localizedString(forLanguageCode: favorite.targetLanguageCode) ?? favorite.targetLanguageCode)
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
                .onDelete(perform: deleteFavorite)
            }
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesManager())
} 