//
//  SettingsView.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import SwiftUI
import AVFoundation  // 🔹 Import AVFoundation for voice selection
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject var viewModel: WordViewModel
    @Environment(\.dismiss) private var dismiss
    
    // State to track if we need to refresh voice options
    @State private var forceVoiceRefresh: Bool = false
    
    @AppStorage("enableTextToSpeech") private var enableTextToSpeech = false
    @AppStorage("favoriteColor") private var favoriteColor: String = "yellow"
    @AppStorage("selectedVoiceForTargetLanguage") private var selectedVoiceForTargetLanguage: String = "com.apple.tts.voice.siri.en-US.premium"
    
    // Notification time settings
    @AppStorage("notificationHour") var notificationHour: Int = 9
    @AppStorage("notificationMinute") var notificationMinute: Int = 0
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    @State private var notificationTime: Date = Date()
    
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
            
            // Notification Settings
            Section(header: Text("Notification Settings")) {
                Toggle("Enable Daily Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { newValue in
                        if newValue {
                            viewModel.scheduleDailyWordNotification()
                        } else {
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyWordNotification"])
                        }
                    }
                
                if !notificationsEnabled {
                    Text("Notifications are currently turned off.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                }
                
                if notificationsEnabled {
                    DatePicker("Notification Time", selection: $notificationTime, displayedComponents: .hourAndMinute)
                        .onChange(of: notificationTime) { newTime in
                            // Extract hour and minute from selected Date
                            let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)
                            notificationHour = components.hour ?? 9
                            notificationMinute = components.minute ?? 0
                            viewModel.scheduleDailyWordNotification()
                        }
                    
                    Button("Disable Notifications") {
                        notificationHour = -1
                        notificationMinute = 0
                        notificationsEnabled = false
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyWordNotification"])
                    }
                    .foregroundColor(.red)
                }
                
                if notificationsEnabled && notificationHour >= 0 {
                    Text("Your next Word of the Day will arrive at \(formattedNotificationTime()).")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                } else if notificationsEnabled && notificationHour == -1 {
                    Text("No daily reminder set.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                }
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
        .onAppear {
            // Set notification time based on saved hour and minute
            var components = DateComponents()
            components.hour = notificationHour
            components.minute = notificationMinute
            if let date = Calendar.current.date(from: components) {
                notificationTime = date
            }
        }
    }
    
    private func formattedNotificationTime() -> String {
        var components = DateComponents()
        components.hour = notificationHour
        components.minute = notificationMinute
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return "Unknown time"
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

