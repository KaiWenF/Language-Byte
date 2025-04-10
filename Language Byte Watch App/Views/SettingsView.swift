//
//  SettingsView.swift
//  Language Byte
//
//  Created by Kevin Franklin on 2/13/25.
//
import SwiftUI
import AVFoundation  // 🔹 Import AVFoundation for voice selection

struct SettingsView: View {
    @AppStorage("favoriteColor") private var favoriteColor: String = "yellow"
    @AppStorage("enableTextToSpeech") private var enableTextToSpeech = false  // 🔹 Store TTS preference
    @AppStorage("selectedEnglishVoice") private var selectedEnglishVoice: String = "com.apple.tts.voice.siri.en-US.premium"
    @AppStorage("selectedSpanishVoice") private var selectedSpanishVoice: String = "com.apple.tts.voice.siri.es-ES.premium"

    @EnvironmentObject var viewModel: WordViewModel  // Access ViewModel

    // 🔹 Load available voices dynamically
    private var englishVoices: [(String, String)] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: "en") }  // 🔹 English voices
            .map { ($0.name, $0.identifier) }
    }

    private var spanishVoices: [(String, String)] {
        AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: "es") }  // 🔹 Spanish voices
            .map { ($0.name, $0.identifier) }
    }

    var body: some View {
        List {
            // 🔹 Favorites Settings
            Section(header: Text("Favorites Settings")) {
                // Picker to choose favorite word color
                Picker("Favorite Word Color", selection: $favoriteColor) {
                    Text("Yellow").tag("yellow")
                    Text("Red").tag("red")
                    Text("Blue").tag("blue")
                    Text("Green").tag("green")
                }
                .pickerStyle(.wheel) // Works best for watchOS

                // Button to clear all favorites
                Button("Clear Favorites") {
                    viewModel.clearAllFavorites()  // 🔹 Use function instead of modifying `favoriteWordPairs` directly
                }
                .foregroundColor(.red)
            }

            // 🔹 Accessibility Settings
            Section(header: Text("Accessibility")) {
                Toggle("Enable Text-to-Speech", isOn: $enableTextToSpeech)
            }

            // 🔹 Voice Settings
            Section(header: Text("Voice Settings")) {
                // English Voice Picker
                Picker("English Voice", selection: $selectedEnglishVoice) {
                    ForEach(englishVoices, id: \.1) { voice in
                        Text(voice.0).tag(voice.1)
                    }
                }
                .pickerStyle(.wheel) // 🔹 Works on watchOS

                // Spanish Voice Picker
                Picker("Spanish Voice", selection: $selectedSpanishVoice) {
                    ForEach(spanishVoices, id: \.1) { voice in
                        Text(voice.0).tag(voice.1)
                    }
                }
                .pickerStyle(.wheel) // 🔹 Works on watchOS
            }
           // Section(header: Text("History")) {
                               // ✅ Corrected NavigationLink
          //                     NavigationLink("View Word History") {
           //                        WordHistoryView().environmentObject(viewModel)  // 🔹 Ensure viewModel is passed
          //                     }
           //                }
                       }
                       .navigationTitle("Settings")  // 🔹 Ensure title appears
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
