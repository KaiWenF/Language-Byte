//
//  WordViewModel.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import SwiftUI
import AVFoundation  // 🔹 Import AVFoundation for Text-to-Speech support

/// The view model that orchestrates loading words and toggling between foreign word / translation.

class WordViewModel: ObservableObject {
    // Keys for UserDefaults.
    private let favoritesKey = "favoriteWordPairs"
    private let selectedCategoryKey = "selectedCategory"
    // ✅ Tracks the current language for TTS
    @Published var currentLanguage: String = "en-US"  // Default to English
    
    // Store user-selected voice preferences
    @AppStorage("selectedEnglishVoice") private var selectedEnglishVoice: String = "com.apple.tts.voice.siri.en-US.premium"
    @AppStorage("selectedSpanishVoice") private var selectedSpanishVoice: String = "com.apple.tts.voice.siri.es-ES.premium"
    @Published var preventNextSpeak: Bool = false  // ✅ Used to prevent speaking after exiting Settings
    
    // All words loaded from JSON.
    @Published var allWords: [WordPair] = []
    
    // The currently selected word pair.
    @Published var currentWord: WordPair?
    
    // Store the history of displayed words
    @AppStorage("wordHistory") private var storedWordHistory: Data?

    @Published var wordHistory: [WordPair] = []  // Local list of history
    
    // The selected category from the Picker.
    @Published var selectedCategory: String = "all" {
        didSet {
            saveSelectedCategory()
        }
    }
    
    // A set to store your favorite word pairs.
    @Published var favoriteWordPairs: Set<WordPair> = [] {
        didSet {
            saveFavorites()
        }
    }
    
    // Determines whether to show the foreign word or its translation.
    @Published var showingForeign: Bool = true

    // 🔹 Store the Text-to-Speech preference (Persistent using @AppStorage)
    @AppStorage("enableTextToSpeech") private var enableTextToSpeech = false

    // 🔹 AVSpeechSynthesizer instance for Text-to-Speech
    private let speechSynthesizer = AVSpeechSynthesizer()

    // Computed property to display the current word.
    var displayWord: String {
        guard let current = currentWord else { return "N/A" }
        return showingForeign ? current.foreignWord : current.translation
    }

    // Computed property to check if the current word is a favorite.
    var isCurrentWordFavorite: Bool {
        guard let current = currentWord else { return false }
        return favoriteWordPairs.contains(current)
    }

    // Computed property for available categories.
    var availableCategories: [String] {
        var categories = ["⚙️ Settings"]  // ✅ Move Settings to the top

        categories.append("all")  // ✅ Default category
        if !favoriteWordPairs.isEmpty {
            categories.append("favorites")
        }

        let uniqueCategories = Set(allWords.map { $0.category.lowercased() })
        categories.append(contentsOf: uniqueCategories.sorted())

        return categories
    }

    // Initializer to load saved preferences.
    init() {
        loadSelectedCategory()
        loadFavorites()
        loadWordHistory()  // 🔹 Load saved words when app starts
    }

    // MARK: - Text-to-Speech (TTS) Method

    /// Speaks a word aloud using Siri's voice, detecting the correct language.
    func speakWord(_ word: String) {
        guard enableTextToSpeech else { return }  // 🔹 Only speak if TTS is enabled

        let utterance = AVSpeechUtterance(string: word)

        // ✅ Always use the correct language from `currentLanguage`
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage)

        utterance.rate = 0.5  // 🔹 Adjust speech speed (0.5 is normal)

        speechSynthesizer.speak(utterance)
    }
    
    

    // MARK: - Word Selection and Toggle Methods
    
    /// Picks a new word from the selected category and speaks it in the correct language.
    func pickRandomWord(shouldSpeak: Bool = true) {
        print("🟢 pickRandomWord() function called!")  // Debugging
        
        let wordsToPick: [WordPair]
        
        switch selectedCategory.lowercased() {
        case "all":
            wordsToPick = allWords
        case "favorites":
            wordsToPick = Array(favoriteWordPairs)
        default:
            wordsToPick = allWords.filter { $0.category.lowercased() == selectedCategory.lowercased() }
        }
        
        if let current = currentWord, wordsToPick.count > 1 {
            let filteredCandidates = wordsToPick.filter { $0 != current }
            currentWord = filteredCandidates.randomElement()
        } else {
            currentWord = wordsToPick.randomElement()
        }

        // ✅ Ensure the correct language is set before speaking
        currentLanguage = showingForeign ? "es-ES" : "en-US"

        // ✅ Prevent speech if `preventNextSpeak` is active
        if preventNextSpeak {
            print("🛑 Skipping speech due to preventNextSpeak flag")
            preventNextSpeak = false  // ✅ Reset flag after skipping speech
            return
        }

        // ✅ Speak the **correctly displayed word**, not just the foreign word
        if shouldSpeak {
            let wordToSpeak = showingForeign ? currentWord?.foreignWord ?? "" : currentWord?.translation ?? ""
            speakWord(wordToSpeak)
        }
    }
    
    /// Toggles the favorite status of the current word.
    func toggleFavorite() {
        guard let word = currentWord else { return }

        if favoriteWordPairs.contains(word) {
            favoriteWordPairs.remove(word)

            // 🔹 If Favorites is now empty, switch back to "All"
            if selectedCategory == "favorites" && favoriteWordPairs.isEmpty {
                selectedCategory = "all"
            }
        } else {
            // 🔹 Prevent duplicate entries by checking before inserting
            if !favoriteWordPairs.contains(word) {
                favoriteWordPairs.insert(word)
            }
        }

        // 🔹 If we're in "Favorites" and we removed a word, pick a new favorite word
        if selectedCategory == "favorites" {
            pickRandomWord()  // Ensure a new word is selected after removal
        }
    }

    /// Clears all words from the favorites list
    func clearAllFavorites() {
        favoriteWordPairs.removeAll()

        // If the user is currently in the "favorites" category, switch them back to "all"
        if selectedCategory == "favorites" {
            selectedCategory = "all"
        }

        pickRandomWord()  // Make sure a new word is selected after clearing
    }

    // MARK: - Persistence Methods

    /// Saves favorite words to UserDefaults
    private func saveFavorites() {
        do {
            let encoder = JSONEncoder()
            let favoritesArray = Array(favoriteWordPairs)
            let data = try encoder.encode(favoritesArray)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("Error saving favorites: \(error)")
        }
    }

    /// Loads favorite words from UserDefaults
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return }
        do {
            let decoder = JSONDecoder()
            let favoritesArray = try decoder.decode([WordPair].self, from: data)
            favoriteWordPairs = Set(favoritesArray)
        } catch {
            print("Error loading favorites: \(error)")
        }
    }

    /// Saves the selected category to UserDefaults
    private func saveSelectedCategory() {
        UserDefaults.standard.set(selectedCategory, forKey: selectedCategoryKey)
    }

    /// Loads the selected category from UserDefaults
    private func loadSelectedCategory() {
        if let savedCategory = UserDefaults.standard.string(forKey: selectedCategoryKey) {
            selectedCategory = savedCategory
        } else {
            selectedCategory = "all"
        }
    }

    // MARK: - Other Methods

    /// Loads words from JSON and picks an initial word.
    func loadWords() {
        let manager = WordDataManager()
        allWords = manager.loadWordsFromJSON()
        pickRandomWord()
    }

   
    /// Toggles between displaying the foreign word and its translation, and speaks the new word aloud.
    func toggleDisplay() {
        showingForeign.toggle()  // 🔹 Switch between foreign word & translation
        
        // ✅ Update the speech language immediately
        currentLanguage = showingForeign ? "es-ES" : "en-US"

        // ✅ Speak the newly displayed word
        if let currentWord = currentWord {
            let wordToSpeak = showingForeign ? currentWord.foreignWord : currentWord.translation
            speakWord(wordToSpeak)
        }
    }
    
    /// Saves the word history to UserDefaults.
     func saveWordHistory() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(wordHistory)
            storedWordHistory = data
        } catch {
            print("Error saving word history: \(error)")
        }
    }

    /// Loads the word history from UserDefaults.
    private func loadWordHistory() {
        guard let data = storedWordHistory else { return }
        do {
            let decoder = JSONDecoder()
            wordHistory = try decoder.decode([WordPair].self, from: data)
        } catch {
            print("Error loading word history: \(error)")
        }
    }
    
    /// Stops any currently speaking text-to-speech playback.
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate) // ✅ Immediately stop speaking
    }

    /// Clears all saved word history.
//    func clearWordHistory() {
//        wordHistory.removeAll()
//        storedWordHistory = nil
//    }
    
    /// ✅ Clears all word history
    func clearWordHistory() {
        wordHistory.removeAll()
        saveWordHistory()  // ✅ Save the empty history list
    }

    /// Loads a new word from the selected category.
    func loadNewWord() {
        pickRandomWord()
    }
    
    func updateSpeechLanguage() {
        // ✅ Ensure the speech language matches the current word display
        currentLanguage = showingForeign ? "es-ES" : "en-US"
        print("[DEBUG] Updated speech language: \(currentLanguage)")
    }
    
    func speakCurrentWord() {
        let utterance = AVSpeechUtterance(string: displayWord)

        // ✅ Ensure correct language is used
        utterance.voice = AVSpeechSynthesisVoice(language: currentLanguage)

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
}
