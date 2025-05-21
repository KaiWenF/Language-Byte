// We will use our mock XCTest implementation
import Foundation
@testable import Language_Byte_Watch_App

class PerformanceTests: XCTestCase {
    var languageManager: LanguageDataManager!
    var wordViewModel: WordViewModel!
    var wordDataManager: WordDataManager!
    
    override func setUp() {
        super.setUp()
        languageManager = LanguageDataManager()
        wordViewModel = WordViewModel()
        wordDataManager = WordDataManager()
    }
    
    override func tearDown() {
        wordViewModel = nil
        languageManager = nil
        wordDataManager = nil
        super.tearDown()
    }
    
    func testLanguagePairLoadingPerformance() {
        // Test the performance of loading language pairs
        self.measure {
            // Initialize a new language manager to force reloading
            let manager = LanguageDataManager()
            _ = manager.availableLanguagePairs
        }
    }
    
    func testWordFilteringPerformance() {
        // Test the performance of filtering words by category
        let allCategories = Set(wordViewModel.allWords.map { $0.category })
        guard let sampleCategory = allCategories.first else {
            XCTFail("No categories available for testing")
            return
        }
        
        self.measure {
            wordViewModel.selectedCategory = sampleCategory
            let _ = wordViewModel.filteredWords
        }
    }
    
    func testRandomWordSelectionPerformance() {
        // Test the performance of random word selection
        self.measure {
            for _ in 0..<100 {
                wordViewModel.pickRandomWord()
            }
        }
    }
    
    func testWordOfTheDaySelectionPerformance() {
        // Test the performance of selecting a word of the day
        self.measure {
            for _ in 0..<10 {
                wordViewModel.selectNewWordOfTheDay()
            }
        }
    }
    
    func testSearchPerformance() {
        // Test search performance with different datasets
        let testWords = wordDataManager.loadWords() ?? []
        
        // Start with small dataset
        let smallWordList = Array(testWords.prefix(50))
        
        self.measure {
            // Search for words containing 'a'
            let _ = performSearch(in: smallWordList, query: "a")
        }
        
        // Medium dataset
        let mediumWordList = Array(testWords.prefix(200))
        
        self.measure {
            // Search for words containing 'e'
            let _ = performSearch(in: mediumWordList, query: "e")
        }
        
        // Full dataset
        let fullWordList = testWords
        
        self.measure {
            // Search for words containing 'o'
            let _ = performSearch(in: fullWordList, query: "o")
        }
    }
    
    func testLanguageSwitchingPerformance() {
        // Test the performance of switching between languages
        let testWords = wordDataManager.loadWords() ?? []
        
        // Create mock language pairs for testing
        let spanishEnglish = LanguagePair(
            sourceLanguage: Language.spanish,
            targetLanguage: Language.english,
            pairs: testWords
        )
        
        let frenchEnglish = LanguagePair(
            sourceLanguage: Language.french,
            targetLanguage: Language.english,
            pairs: testWords
        )
        
        self.measure {
            // Simulate language switching
            wordViewModel.allWords = testWords
            wordViewModel.allWords = testWords
            wordViewModel.allWords = testWords
        }
    }
    
    func testQuizGenerationPerformance() {
        // Test quiz question generation performance
        let quizViewModel = QuizViewModel()
        
        self.measure {
            for _ in 0..<10 {
                _ = quizViewModel.generateQuestion()
            }
        }
    }
    
    func testDashboardStatsCalculationPerformance() {
        // Set up some sample data
        for i in 0..<100 {
            UserDefaults.standard.set(i, forKey: "day_\(i)_words")
        }
        
        // Test calculation of dashboard stats
        self.measure {
            let dashboard = DashboardViewModel()
            _ = dashboard.calculateWeeklyProgress()
            _ = dashboard.calculateTotalWordsLearned()
            _ = dashboard.calculateCurrentStreak()
        }
        
        // Clean up
        for i in 0..<100 {
            UserDefaults.standard.removeObject(forKey: "day_\(i)_words")
        }
    }
    
    // MARK: - Helper Methods
    
    func performSearch(in wordList: [WordPair], query: String) -> [WordPair] {
        return wordList.filter { 
            $0.sourceWord.lowercased().contains(query.lowercased()) || 
            $0.targetWord.lowercased().contains(query.lowercased())
        }
    }
} 