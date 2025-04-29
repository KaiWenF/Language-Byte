import Testing
import SwiftUI
import Foundation
import UserNotifications
@testable import Language_Byte_Watch_App

struct LanguageDataManagerTests {
    
    @Test func testLanguageDataManagerInitialization() {
        // Arrange & Act
        let manager = LanguageDataManager()
        
        // Assert
        #expect(!manager.languagePairs.isEmpty)
    }
    
    @Test func testGetLanguagePair() {
        // Arrange
        let manager = LanguageDataManager()
        
        // Act
        let pair = manager.getLanguagePair(source: "en", target: "es")
        
        // Assert
        #expect(pair != nil)
        if let pair = pair {
            #expect(pair.sourceLanguage.code == "en")
            #expect(pair.targetLanguage.code == "es")
        }
    }
    
    @Test func testGetAvailableLanguagePairsDisplay() {
        // Arrange
        let manager = LanguageDataManager()
        
        // Act
        let displayStrings = manager.getAvailableLanguagePairsDisplay()
        
        // Assert
        #expect(!displayStrings.isEmpty)
        
        // Each string should match pattern "SourceLanguage → TargetLanguage"
        for displayString in displayStrings {
            #expect(displayString.contains("→"))
        }
    }
    
    @Test func testGetLanguagePairIndex() {
        // Arrange
        let manager = LanguageDataManager()
        let displayStrings = manager.getAvailableLanguagePairsDisplay()
        
        // Make sure we have at least one display string
        guard !displayStrings.isEmpty else {
            #expect(false, "No display strings available")
            return
        }
        
        // Act
        let firstDisplayString = displayStrings[0]
        let index = manager.getLanguagePairIndex(from: firstDisplayString)
        
        // Assert
        #expect(index == 0)
    }
    
    @Test func testGetSpeechCode() {
        // This is a private method that we can't test directly
        // Instead, we'll verify that our language pairs have correct speech codes
        
        // Arrange
        let manager = LanguageDataManager()
        
        // Act & Assert
        for pair in manager.languagePairs {
            let sourceCode = pair.sourceLanguage.code
            let sourceSpeechCode = pair.sourceLanguage.speechCode
            
            #expect(sourceSpeechCode.starts(with: sourceCode))
            #expect(sourceSpeechCode.count > sourceCode.count) // Should include region
        }
    }
}

struct NotificationManagerTests {
    
    @Test func testScheduleDailyNotification() async {
        // Set up mock time
        let hour = 9
        let minute = 30
        
        // Create the notification manager
        let manager = NotificationManager()
        
        // Schedule the notification - fix to match actual method signature
        manager.scheduleDailyNotification(hour: hour, minute: minute)
        
        // Clean up - no need to await this operation
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyWord"])
    }
    
    @Test func testRequestAuthorization() {
        // Arrange
        let manager = NotificationManager()
        
        // Act
        manager.requestAuthorization()
        
        // Assert - Just checking that this doesn't throw errors
        // In a real app, this would include more assertions about the notification center state
    }
} 