//
//  WordViewModel.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import SwiftUI
import AVFoundation
import UserNotifications

/// The view model that orchestrates loading words and toggling between foreign word / translation.
class WordViewModel: ObservableObject {
    // Keys for UserDefaults.
    private let favoritesKey = "favoriteWordPairs"
    private let selectedCategoryKey = "selectedCategory"
    private let selectedLanguagePairKey = "selectedLanguagePair"
    
    // UI state properties
    @Published var showLanguagePicker: Bool = false
    
    // Language-related properties
    @Published var selectedLanguagePair: LanguagePair?
    @Published var availableLanguagePairs: [LanguagePair] = []
    
    // AppStorage properties for source and target languages
    @AppStorage("selectedSourceLanguage") var selectedSourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") var selectedTargetLanguage: String = "es"
    
    // Word of the Day properties
    @AppStorage("wordOfTheDaySource") public var wordOfTheDaySource: String = ""
    @AppStorage("wordOfTheDayTarget") public var wordOfTheDayTarget: String = ""
    @AppStorage("wordOfTheDaySourceLanguage") public var wordOfTheDaySourceLanguage: String = ""
    @AppStorage("wordOfTheDayTargetLanguage") public var wordOfTheDayTargetLanguage: String = ""
    @AppStorage("wordOfTheDayDate") public var wordOfTheDayDate: String = ""
    
    // Notification properties
    @AppStorage("notificationHour") public var notificationHour: Int = 9
    @AppStorage("notificationMinute") public var notificationMinute: Int = 0
    @AppStorage("notificationsEnabled") public var notificationsEnabled: Bool = true
    
    // Daily progress tracking
    @AppStorage("dailyGoal") var dailyGoal: Int = 10
    @AppStorage("wordsStudiedToday") var wordsStudiedToday: Int = 0
    @AppStorage("lastStudyDate") var lastStudyDate: String = ""
    
    // Store the current display language code for TTS
    @Published var currentSpeechCode: String = "en-US"  // Default to English
    
    // Store user-selected voice preferences
    @AppStorage("selectedVoiceForTargetLanguage") var selectedVoiceForTargetLanguage: String = ""
    @Published var preventNextSpeak: Bool = false
    
    // Words from the selected language pair
    @Published var allWords: [WordPair] = []
    
    // The currently selected word pair.
    @Published var currentWord: WordPair?
    
    // Store the history of displayed words
    @AppStorage("wordHistory") private var storedWordHistory: Data?
    @Published var wordHistory: [WordPair] = []
    
    // The selected category from the Picker with @AppStorage persistence
    @AppStorage("selectedCategory") var selectedCategoryRawValue: String = "All"
    
    var selectedCategory: String? {
        get {
            selectedCategoryRawValue == "All" ? nil : selectedCategoryRawValue
        }
        set {
            selectedCategoryRawValue = newValue ?? "All"
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

    // Text-to-Speech preference
    @AppStorage("enableTextToSpeech") private var enableTextToSpeech = false

    // AVSpeechSynthesizer instance for Text-to-Speech
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    // Language data manager
    private let languageManager = LanguageDataManager()

    // Computed property to display the current word.
    var displayWord: String {
        guard let current = currentWord else { return "N/A" }
        return showingForeign ? current.foreignWord : current.translation
    }
    
    // Computed property that filters words by selectedCategory + language pair
    var filteredWords: [WordPair] {
        return allWords.filter { word in
            if let category = selectedCategory {
                return word.category.lowercased() == category.lowercased()
            } else {
                return true  // If no category is selected, include all words
            }
        }
    }

    // Computed property to check if the current word is a favorite.
    var isCurrentWordFavorite: Bool {
        guard let current = currentWord else { return false }
        return favoriteWordPairs.contains(current)
    }
    
    // Computed property to access today's Word of the Day
    var wordOfTheDay: WordPair {
        WordPair(
            foreignWord: wordOfTheDayTarget,
            translation: wordOfTheDaySource,
            category: "Word of the Day"
        )
    }

    // Computed property for available categories.
    var availableCategories: [String] {
        var categories = ["All"]  // Default category always first
        
        if !favoriteWordPairs.isEmpty {
            categories.append("Favorites")
        }

        // Add actual word categories from the word data
        let uniqueCategories = Set(allWords.map { $0.category.lowercased().capitalized })
        categories.append(contentsOf: uniqueCategories.sorted())

        return categories
    }

    // Available language pairs for selection
    var languagePairOptions: [String] {
        return languageManager.getAvailableLanguagePairsDisplay()
    }

    // Initializer to load saved preferences and data.
    init() {
        loadSelectedCategory()
        loadFavorites()
        loadWordHistory()
        loadLanguageData()
        
        // Request notification permissions
        requestNotificationPermissions()
        
        // Schedule notifications with saved time
        scheduleDailyWordNotification()
    }
    
    // MARK: - Notification Methods
    
    /// Request permissions for sending notifications
    private func requestNotificationPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notifications allowed.")
            } else {
                print("Notifications not allowed.")
            }
        }
    }
    
    /// Display language name helper function
    func displayLanguageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "ja": return "Japanese"
        case "zh": return "Chinese"
        default: return code.uppercased()
        }
    }
    
    /// Schedules a daily notification for the Word of the Day at the user's preferred time
    public func scheduleDailyWordNotification() {
        let center = UNUserNotificationCenter.current()

        // Cancel any existing scheduled notification first
        center.removePendingNotificationRequests(withIdentifiers: ["DailyWordNotification"])
        
        // Don't schedule if notifications are disabled or hour is -1 (no notification)
        if !notificationsEnabled || notificationHour == -1 {
            return
        }

        // Build the new notification
        let content = UNMutableNotificationContent()
        content.title = "Word of the Day"
        content.body = "\(wordOfTheDayTarget) means \(wordOfTheDaySource) in \(displayLanguageName(for: wordOfTheDayTargetLanguage))!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = notificationHour
        dateComponents.minute = notificationMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "DailyWordNotification", content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Word of the Day Methods
    
    /// Checks if Word of the Day needs to be refreshed and updates if necessary
    public func updateWordOfTheDayIfNeeded() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if today != wordOfTheDayDate {
            selectNewWordOfTheDay()
            wordOfTheDayDate = today
            
            // Update the notification with the new word
            scheduleDailyWordNotification()
        }
    }
    
    /// Selects a new Word of the Day
    public func selectNewWordOfTheDay() {
        if !allWords.isEmpty {
            if let randomWord = allWords.randomElement() {
                wordOfTheDaySource = randomWord.translation
                wordOfTheDayTarget = randomWord.foreignWord
                wordOfTheDaySourceLanguage = selectedLanguagePair?.sourceLanguage.code ?? "en"
                wordOfTheDayTargetLanguage = selectedLanguagePair?.targetLanguage.code ?? "es"
            }
        }
    }
    
    // MARK: - Language Loading
    
    /// Loads language data and sets the initial language pair
    func loadLanguageData() {
        languageManager.loadLanguageData()
        availableLanguagePairs = languageManager.languagePairs
        
        // First try loading saved AppStorage selection
        loadSavedLanguageSelection()
        
        // Next try loading from the language pair UserDefaults key 
        if selectedLanguagePair == nil {
            loadSelectedLanguagePair()
        }
        
        // If still no selection and we have options, use the first pair as default
        if selectedLanguagePair == nil && !availableLanguagePairs.isEmpty {
            selectLanguagePair(availableLanguagePairs[0])
        }
        
        // Check and update Word of the Day if needed
        updateWordOfTheDayIfNeeded()
    }
    
    /// Load language pair based on saved source and target language codes in AppStorage
    func loadSavedLanguageSelection() {
        // Make sure we have language pairs to select from
        guard !availableLanguagePairs.isEmpty else { return }
        
        // Find matching language pair from available pairs
        if let matchingPair = availableLanguagePairs.first(where: { 
            $0.sourceLanguage.code == selectedSourceLanguage && 
            $0.targetLanguage.code == selectedTargetLanguage 
        }) {
            selectLanguagePair(matchingPair)
            print("Loaded saved language selection: \(selectedSourceLanguage)-\(selectedTargetLanguage)")
        }
    }
    
    /// Sets the currently selected language pair and loads its words
    func selectLanguagePair(_ languagePair: LanguagePair) {
        print("🔍 Selecting language pair: \(languagePair.sourceLanguage.name) → \(languagePair.targetLanguage.name)")
        print("📚 Word count in this pair: \(languagePair.pairs.count)")
        
        selectedLanguagePair = languagePair
        allWords = languagePair.pairs
        saveSelectedLanguagePair()
        
        // Update AppStorage values for source and target languages
        selectedSourceLanguage = languagePair.sourceLanguage.code
        selectedTargetLanguage = languagePair.targetLanguage.code
        
        print("🔤 Updated AppStorage language codes: \(selectedSourceLanguage) → \(selectedTargetLanguage)")
        
        // Update speech code based on whether showing foreign or translation
        updateSpeechLanguage()
        
        // Select a word from the new language pair
        pickRandomWord()
        
        // Check if we actually have a current word
        if let current = currentWord {
            print("✅ Successfully selected word: \(current.foreignWord) = \(current.translation)")
        } else {
            print("❌ Failed to select a word after language change")
        }
    }
    
    /// Selects a language pair by its display name
    func selectLanguagePair(byDisplay displayName: String) {
        if let index = languageManager.getLanguagePairIndex(from: displayName),
           index < availableLanguagePairs.count {
            selectLanguagePair(availableLanguagePairs[index])
        }
    }
    
    /// Saves the selected language pair to UserDefaults
    private func saveSelectedLanguagePair() {
        guard let selectedPair = selectedLanguagePair else { return }
        UserDefaults.standard.set(
            "\(selectedPair.sourceLanguage.code)-\(selectedPair.targetLanguage.code)",
            forKey: selectedLanguagePairKey
        )
    }
    
    /// Loads the selected language pair from UserDefaults
    private func loadSelectedLanguagePair() {
        // First try loading from the explicit language pair key
        if let savedPairId = UserDefaults.standard.string(forKey: selectedLanguagePairKey) {
            // Format is "source-target" (e.g., "en-es")
            let components = savedPairId.split(separator: "-")
            if components.count == 2 {
                let source = String(components[0])
                let target = String(components[1])
                
                selectedLanguagePair = languageManager.getLanguagePair(source: source, target: target)
                
                if let pair = selectedLanguagePair {
                    allWords = pair.pairs
                    
                    // Sync AppStorage values
                    selectedSourceLanguage = pair.sourceLanguage.code
                    selectedTargetLanguage = pair.targetLanguage.code
                }
            }
        } 
        // If no language pair was loaded, try using the separately stored source/target
        else if let pair = languageManager.getLanguagePair(source: selectedSourceLanguage, target: selectedTargetLanguage) {
            selectedLanguagePair = pair
            allWords = pair.pairs
        }
    }

    // MARK: - Text-to-Speech Methods

    /// Speaks a word aloud using the correct language.
    func speakWord(_ word: String) {
        guard enableTextToSpeech else { return }

        let utterance = AVSpeechUtterance(string: word)

        // First try to use user-selected voice if available
        if !selectedVoiceForTargetLanguage.isEmpty, 
           let voice = AVSpeechSynthesisVoice(identifier: selectedVoiceForTargetLanguage) {
            utterance.voice = voice
            print("[DEBUG] Using custom voice: \(selectedVoiceForTargetLanguage)")
        } else {
            // Fall back to system default for the language
            utterance.voice = AVSpeechSynthesisVoice(language: currentSpeechCode)
            print("[DEBUG] Using default voice for: \(currentSpeechCode)")
        }
        
        utterance.rate = 0.5

        speechSynthesizer.speak(utterance)
    }
    
    /// Updates the speech language based on the current display
    func updateSpeechLanguage() {
        guard let languagePair = selectedLanguagePair else { return }
        
        // Set speech code based on whether showing foreign or translation
        if showingForeign {
            currentSpeechCode = languagePair.targetLanguage.speechCode
        } else {
            currentSpeechCode = languagePair.sourceLanguage.speechCode
        }
        
        print("[DEBUG] Updated speech language: \(currentSpeechCode)")
    }

    // MARK: - Daily Progress Methods
    
    /// Increments the words studied today counter and checks if we need to reset
    func incrementWordsStudied() {
        checkAndResetDailyProgress()
        wordsStudiedToday += 1
    }
    
    /// Checks if we need to reset daily progress based on the date
    func checkAndResetDailyProgress() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if today != lastStudyDate {
            wordsStudiedToday = 0
            lastStudyDate = today
        }
    }

    // MARK: - Word Selection and Toggle Methods
    
    /// Helper function to set/reset the category
    func selectCategory(_ category: String?) {
        selectedCategory = category
    }
    
    /// Load the saved category from UserDefaults
    private func loadSelectedCategory() {
        if let savedCategory = UserDefaults.standard.string(forKey: selectedCategoryKey) {
            selectedCategory = savedCategory
        }
    }
    
    /// Picks a random word from the current language pair
    func pickRandomWord() {
        guard !allWords.isEmpty else {
            print("❌ No words available in current language pair!")
            return
        }
        
        // Filter words based on the current category
        var wordsToChooseFrom = allWords
        
        // Special category handling
        if let category = selectedCategory {
            if category.lowercased() == "favorites" {
                // Only use favorites from the current language
                wordsToChooseFrom = Array(favoriteWordPairs.filter { 
                    allWords.contains($0) 
                })
            } 
            else if category.lowercased() != "all" {
                // Filter by the selected category
                wordsToChooseFrom = allWords.filter { 
                    $0.category.lowercased() == category.lowercased() 
                }
            }
        }
        
        // Safety check - if no words match the filter, use all words
        if wordsToChooseFrom.isEmpty {
            print("⚠️ No words match the filter '\(selectedCategory ?? "no category")', using all words instead")
            wordsToChooseFrom = allWords
        }
        
        // Pick a random word
        currentWord = wordsToChooseFrom.randomElement()
        showingForeign = true
        incrementWordsStudied()
        
        print("📝 Selected word: \(currentWord?.foreignWord ?? "none") (\(currentWord?.category ?? "no category"))")
    }
    
    /// Toggles the favorite status of the current word.
    func toggleFavorite() {
        guard let word = currentWord else { return }

        if favoriteWordPairs.contains(word) {
            favoriteWordPairs.remove(word)

            // If Favorites is now empty, switch back to "All"
            if selectedCategory == "favorites" && favoriteWordPairs.isEmpty {
                selectedCategory = nil
            }
        } else {
            // Prevent duplicate entries
            if !favoriteWordPairs.contains(word) {
                favoriteWordPairs.insert(word)
            }
        }

        // If we're in "Favorites" and we removed a word, pick a new favorite word
        if selectedCategory == "favorites" {
            pickRandomWord()
        }
    }

    /// Clears all words from the favorites list
    func clearAllFavorites() {
        favoriteWordPairs.removeAll()

        // If the user is currently in the "favorites" category, switch them back to "all"
        if selectedCategory == "favorites" {
            selectedCategory = nil
        }

        pickRandomWord()
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

    // MARK: - Other Methods
   
    /// Toggles between displaying the foreign word and its translation, and speaks the new word aloud.
    func toggleDisplay() {
        showingForeign.toggle()
        
        // Update the speech language immediately
        updateSpeechLanguage()

        // Speak the newly displayed word
        speakWord(displayWord)
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
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    /// Clears all word history
    func clearWordHistory() {
        wordHistory.removeAll()
        saveWordHistory()
    }

    /// Speaks the current word
    func speakCurrentWord() {
        speakWord(displayWord)
    }
}
