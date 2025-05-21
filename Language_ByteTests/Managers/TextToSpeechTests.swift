import XCTest
import AVFoundation
@testable import Language_Byte_Watch_App

class TextToSpeechTests: XCTestCase {
    var speechManager: MockSpeechManager!
    var languageManager: LanguageDataManager!
    
    override func setUp() {
        super.setUp()
        speechManager = MockSpeechManager()
        languageManager = LanguageDataManager()
    }
    
    override func tearDown() {
        speechManager = nil
        super.tearDown()
    }
    
    func testSpeakForeignWord() {
        // Given
        let word = "hola"
        let languageCode = "es-ES"
        
        // When
        speechManager.speakWord(word, languageCode: languageCode)
        
        // Then
        XCTAssertTrue(speechManager.speakCalled, "Speech method should be called")
        XCTAssertEqual(speechManager.lastSpokenWord, word, "The correct word should be spoken")
        XCTAssertEqual(speechManager.lastLanguageCode, languageCode, "The correct language code should be used")
    }
    
    func testSpeechRateConfiguration() {
        // Given - Different speech rates
        let slowRate: Float = 0.4
        let normalRate: Float = 0.5
        let fastRate: Float = 0.6
        
        // When - Setting different rates
        speechManager.setSpeechRate(slowRate)
        
        // Then
        XCTAssertEqual(speechManager.currentRate, slowRate, "Speech rate should be configurable")
        
        // Test normal rate
        speechManager.setSpeechRate(normalRate)
        XCTAssertEqual(speechManager.currentRate, normalRate, "Speech rate should update correctly")
        
        // Test fast rate
        speechManager.setSpeechRate(fastRate)
        XCTAssertEqual(speechManager.currentRate, fastRate, "Speech rate should update correctly")
    }
    
    func testSpeechPitchConfiguration() {
        // Given - Different speech pitches
        let lowPitch: Float = 0.8
        let normalPitch: Float = 1.0
        let highPitch: Float = 1.2
        
        // When - Setting different pitches
        speechManager.setSpeechPitch(lowPitch)
        
        // Then
        XCTAssertEqual(speechManager.currentPitch, lowPitch, "Speech pitch should be configurable")
        
        // Test normal pitch
        speechManager.setSpeechPitch(normalPitch)
        XCTAssertEqual(speechManager.currentPitch, normalPitch, "Speech pitch should update correctly")
        
        // Test high pitch
        speechManager.setSpeechPitch(highPitch)
        XCTAssertEqual(speechManager.currentPitch, highPitch, "Speech pitch should update correctly")
    }
    
    func testLanguageVoiceSelection() {
        // Test Spanish voice selection
        let spanishCode = "es-ES"
        speechManager.speakWord("hola", languageCode: spanishCode)
        XCTAssertEqual(speechManager.lastVoiceLanguage, spanishCode, "Spanish voice should be selected")
        
        // Test French voice selection
        let frenchCode = "fr-FR"
        speechManager.speakWord("bonjour", languageCode: frenchCode)
        XCTAssertEqual(speechManager.lastVoiceLanguage, frenchCode, "French voice should be selected")
        
        // Test default voice fallback for unsupported language
        let unsupportedCode = "xx-XX"
        speechManager.speakWord("test", languageCode: unsupportedCode)
        XCTAssertEqual(speechManager.lastVoiceLanguage, speechManager.defaultLanguageCode, "Default voice should be used for unsupported language")
    }
    
    func testStopSpeaking() {
        // Given
        speechManager.isSpeaking = true
        
        // When
        speechManager.stopSpeaking()
        
        // Then
        XCTAssertTrue(speechManager.stopCalled, "Stop speaking method should be called")
        XCTAssertFalse(speechManager.isSpeaking, "Speaking state should be updated")
    }
    
    func testVoiceAvailability() {
        // Test availability check
        let supportedCode = "en-US"
        XCTAssertTrue(speechManager.isVoiceAvailable(for: supportedCode), "English voice should be available")
        
        let unsupportedCode = "xx-XX"
        XCTAssertFalse(speechManager.isVoiceAvailable(for: unsupportedCode), "Unsupported voice should not be available")
    }
}

// MARK: - Mock Classes

class MockSpeechManager {
    var speakCalled = false
    var stopCalled = false
    var isSpeaking = false
    var lastSpokenWord = ""
    var lastLanguageCode = ""
    var lastVoiceLanguage = ""
    var currentRate: Float = 0.5
    var currentPitch: Float = 1.0
    var defaultLanguageCode = "en-US"
    var availableVoices = ["en-US", "es-ES", "fr-FR", "de-DE", "it-IT", "ja-JP"]
    
    func speakWord(_ word: String, languageCode: String) {
        speakCalled = true
        lastSpokenWord = word
        lastLanguageCode = languageCode
        
        // Set voice language, defaulting if needed
        if isVoiceAvailable(for: languageCode) {
            lastVoiceLanguage = languageCode
        } else {
            lastVoiceLanguage = defaultLanguageCode
        }
        
        isSpeaking = true
    }
    
    func stopSpeaking() {
        stopCalled = true
        isSpeaking = false
    }
    
    func setSpeechRate(_ rate: Float) {
        currentRate = rate
    }
    
    func setSpeechPitch(_ pitch: Float) {
        currentPitch = pitch
    }
    
    func isVoiceAvailable(for languageCode: String) -> Bool {
        return availableVoices.contains(languageCode)
    }
} 