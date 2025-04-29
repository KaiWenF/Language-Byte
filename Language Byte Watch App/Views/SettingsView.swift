//
//  SettingsView.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import SwiftUI
import AVFoundation  // 🔹 Import AVFoundation for voice selection

struct SettingsView: View {
    @EnvironmentObject var viewModel: WordViewModel
    @Environment(\.dismiss) private var dismiss
    
    // State to track if we need to refresh voice options
    @State private var forceVoiceRefresh: Bool = false
    
    @AppStorage("enableTextToSpeech") private var enableTextToSpeech = false
    @AppStorage("favoriteColor") private var favoriteColor: String = "yellow"
    @AppStorage("selectedVoiceForTargetLanguage") private var selectedVoiceForTargetLanguage: String = "com.apple.tts.voice.siri.en-US.premium"
    
    // Dynamic voice selection based on target language
    private var availableVoices: [(String, String)] {
        let targetLanguage = viewModel.selectedLanguagePair?.targetLanguage.code ?? "es"
        return AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: targetLanguage.prefix(2)) }
            .map { ($0.name, $0.identifier) }
    }

    var colorOptions = ["yellow", "blue", "green", "orange", "pink", "purple", "red"]

    var body: some View {
        List {
            Section(header: Text("Text-to-Speech")) {
                Toggle("Enable Speech", isOn: $enableTextToSpeech)
                    .onChange(of: enableTextToSpeech) { _ in
                        // Stop any current speaking when toggling
                        viewModel.stopSpeaking()
                    }
                
                if enableTextToSpeech {
                    Button("Test Speech") {
                        viewModel.speakCurrentWord()
                    }
                }
            }
            
            Section(header: Text("Appearance")) {
                Picker("Favorite Color", selection: $favoriteColor) {
                    ForEach(colorOptions, id: \.self) { color in
                        Text(color.capitalized)
                            .foregroundColor(colorFromString(color))
                            .tag(color)
                    }
                }
            }
            
            // 🔹 Accessibility Settings
            Section(header: Text("Accessibility")) {
                Toggle("Enable Text-to-Speech", isOn: $enableTextToSpeech)
                    .onChange(of: enableTextToSpeech) { _ in
                        // Stop any current speaking when toggling
                        viewModel.stopSpeaking()
                    }
            }

            // 🔹 Dynamic Voice Settings for Target Language
            Section(header: Text("Voice Settings")) {
                // Determine language name for display
                let languageName = viewModel.selectedLanguagePair?.targetLanguage.name ?? "Target"
                
                Picker("\(languageName) Voice", selection: $selectedVoiceForTargetLanguage) {
                    ForEach(availableVoices, id: \.1) { voice in
                        Text(voice.0).tag(voice.1)
                    }
                }
                .pickerStyle(.wheel)
            }
            .id(viewModel.selectedLanguagePair?.targetLanguage.code) // Force refresh when language changes
            .animation(.easeInOut, value: viewModel.selectedLanguagePair?.targetLanguage.code) // Smooth transition animation
            
            Section(header: Text("Language Settings")) {
                Button("Change Language") {
                    viewModel.showLanguagePicker = true
                }
                .foregroundColor(.blue)
            }

            // 🔹 Storage Settings
            Section(header: Text("Storage")) {
                Button("Clear Favorites") {
                    viewModel.clearAllFavorites()
                }
                .foregroundColor(.red)
                
                Button("Clear History") {
                    viewModel.clearWordHistory()
                }
                .foregroundColor(.red)
            }
            
            Section {
                Button("Done") {
                    viewModel.preventNextSpeak = true
                    dismiss()
                }
                .foregroundColor(.blue)
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $viewModel.showLanguagePicker, onDismiss: {
            // Force refresh the voice settings when returning from language selection
            forceVoiceRefresh.toggle()
        }) {
            LanguageSelectionView()
                .environmentObject(viewModel)
        }
        .onChange(of: forceVoiceRefresh) { _ in
            // If the selected voice isn't valid for the new language, reset to empty string
            // which will make the view model fall back to the system default
            let targetCode = viewModel.selectedLanguagePair?.targetLanguage.code ?? "es"
            let isVoiceValid = AVSpeechSynthesisVoice.speechVoices()
                .filter { $0.language.starts(with: targetCode.prefix(2)) }
                .contains(where: { $0.identifier == selectedVoiceForTargetLanguage })
                
            if !isVoiceValid {
                selectedVoiceForTargetLanguage = ""
            }
        }
    }
}

// 🔹 Helper function to convert color name to SwiftUI Color
func colorFromString(_ colorName: String) -> Color {
    switch colorName {
    case "yellow": return .yellow
    case "red": return .red
    case "blue": return .blue
    case "green": return .green
    default: return .primary
    }
}

#Preview {
    SettingsView()
        .environmentObject(WordViewModel())
}
