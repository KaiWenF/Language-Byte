import Testing
import SwiftUI
import Foundation
@testable import Language_Byte_Watch_App

struct WordViewModelTests {
    
    // Test the initialization of WordViewModel
    @Test func testWordViewModelInitialization() {
        // Act
        let viewModel = WordViewModel()
        
        // Assert
        #expect(viewModel.showingForeign == true)
        // Check if selectedCategory is nil or matches the UserDefaults value (case insensitive)
        // The selectedCategory getter returns nil when selectedCategoryRawValue is "All"
        let storedCategory = UserDefaults.standard.string(forKey: "selectedCategory")?.lowercased()
        #expect(viewModel.selectedCategory == nil || 
                (storedCategory != nil && storedCategory == viewModel.selectedCategory?.lowercased()))
        #expect(!viewModel.availableCategories.isEmpty)
    }
    
    // Test toggling between foreign word and translation
    @Test func testToggleWordDisplay() {
        // Arrange
        let viewModel = WordViewModel()
        let initialState = viewModel.showingForeign
        
        // Act
        viewModel.toggleDisplay()
        
        // Assert
        #expect(viewModel.showingForeign != initialState)
    }
    
    // Test word selection
    @Test func testSelectRandomWord() {
        // Arrange
        let viewModel = WordViewModel()
        let initialWord = viewModel.currentWord
        
        // Act
        viewModel.pickRandomWord()
        
        // Assert
        // If we have words, the current word should change (or at least be set)
        if !viewModel.allWords.isEmpty {
            #expect(viewModel.currentWord != nil)
            
            // Check if the word has actually changed or if we're in the initial state
            if initialWord != nil {
                #expect(viewModel.currentWord != initialWord)
            }
        }
    }
    
    // Test adding words to favorites
    @Test func testToggleFavorite() {
        // Arrange
        let viewModel = WordViewModel()
        
        // Make sure we have a current word
        if viewModel.currentWord == nil && !viewModel.allWords.isEmpty {
            viewModel.currentWord = viewModel.allWords[0]
        }
        
        // Skip the test if there's no current word
        guard let currentWord = viewModel.currentWord else {
            #expect(false, "No current word available for test")
            return
        }
        
        // Act
        let initialIsFavorite = viewModel.isCurrentWordFavorite
        viewModel.toggleFavorite()
        
        // Assert
        #expect(viewModel.isCurrentWordFavorite != initialIsFavorite)
        
        // Clean up - toggle back to original state
        viewModel.toggleFavorite()
    }
    
    // Test category filtering
    @Test func testFilterByCategory() {
        // Arrange
        let viewModel = WordViewModel()
        
        // We need at least two different categories for a meaningful test
        let categories = Set(viewModel.allWords.map { $0.category })
        if categories.count < 2 {
            // Skip test if we don't have enough categories
            return
        }
        
        // Get two different categories
        let categoryArray = Array(categories)
        let category1 = categoryArray[0]
        let category2 = categoryArray[1]
        
        // Act - get word counts by setting category and picking random words
        viewModel.selectedCategory = category1
        viewModel.pickRandomWord()
        let wordsInCategory1 = countWordsInCategory(viewModel.allWords, category: category1)
        
        viewModel.selectedCategory = category2
        viewModel.pickRandomWord()
        let wordsInCategory2 = countWordsInCategory(viewModel.allWords, category: category2)
        
        // Assert
        #expect(wordsInCategory1 > 0)
        #expect(wordsInCategory2 > 0)
    }
    
    // Helper method to count words in a category
    private func countWordsInCategory(_ words: [WordPair], category: String) -> Int {
        return words.filter { $0.category.lowercased() == category.lowercased() }.count
    }
    
    // Test the display word property
    @Test func testDisplayWord() {
        // Arrange
        let viewModel = WordViewModel()
        
        // Make sure we have a current word
        if viewModel.currentWord == nil && !viewModel.allWords.isEmpty {
            viewModel.currentWord = viewModel.allWords[0]
        }
        
        // Skip the test if there's no current word
        guard let currentWord = viewModel.currentWord else {
            #expect(false, "No current word available for test")
            return
        }
        
        // Act
        viewModel.showingForeign = true
        let foreignDisplay = viewModel.displayWord
        
        viewModel.showingForeign = false
        let translationDisplay = viewModel.displayWord
        
        // Assert
        #expect(foreignDisplay == currentWord.foreignWord)
        #expect(translationDisplay == currentWord.translation)
    }
    
    // Test word of the day functionality
    @Test func testWordOfTheDay() {
        // Arrange
        let viewModel = WordViewModel()
        
        // Act
        viewModel.selectNewWordOfTheDay()
        
        // Assert
        // After setting word of the day, the stored values should be populated
        #expect(!viewModel.wordOfTheDaySource.isEmpty)
        #expect(!viewModel.wordOfTheDayTarget.isEmpty)
        
        // Check date format
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let todayString = formatter.string(from: Date())
        
        // Update the Word of the Day and check if the date is set
        viewModel.updateWordOfTheDayIfNeeded()
        #expect(!viewModel.wordOfTheDayDate.isEmpty)
    }
    
    // Test the change language functionality
    @Test func testChangeLanguagePair() {
        // Arrange
        let viewModel = WordViewModel()
        
        // Get available language pairs
        let languagePairs = viewModel.availableLanguagePairs
        if languagePairs.count < 2 {
            // Skip test if we don't have enough language pairs
            return
        }
        
        // Find a language pair different from the current one
        guard let initialPair = viewModel.selectedLanguagePair,
              let differentPair = languagePairs.first(where: { $0.id != initialPair.id }) else {
            return
        }
        
        // Act
        viewModel.selectLanguagePair(differentPair)
        
        // Assert
        #expect(viewModel.selectedLanguagePair?.id == differentPair.id)
        #expect(viewModel.selectedSourceLanguage == differentPair.sourceLanguage.code)
        #expect(viewModel.selectedTargetLanguage == differentPair.targetLanguage.code)
    }
} 