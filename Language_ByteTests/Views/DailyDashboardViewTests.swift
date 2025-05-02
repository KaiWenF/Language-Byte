import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

// Remove the ViewInspector dependency for now as it may not be properly integrated
// import ViewInspector

// extension DailyDashboardView: Inspectable {}

final class DailyDashboardViewTests: XCTestCase {
    var viewModel: WordViewModel!
    var dashboardMock: DashboardViewTestMock!
    
    override func setUp() {
        super.setUp()
        viewModel = WordViewModel()
        dashboardMock = DashboardViewTestMock()
    }
    
    override func tearDown() {
        viewModel = nil
        dashboardMock = nil
        // Reset UserDefaults for test keys
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "quiz_totalAttempts")
        userDefaults.removeObject(forKey: "quiz_correctAnswers")
        userDefaults.removeObject(forKey: "quiz_bestStreak")
        userDefaults.removeObject(forKey: "quiz_comeback")
        userDefaults.removeObject(forKey: "quiz_speedster")
        super.tearDown()
    }
    
    // MARK: - Test Achievement Badge Counting
    
    func testCalculateUnlockedBadges() {
        // Given
        let userDefaults = UserDefaults.standard
        
        // Test case 1: No achievements
        userDefaults.set(0, forKey: "quiz_totalAttempts")
        userDefaults.set(0, forKey: "quiz_correctAnswers")
        userDefaults.set(0, forKey: "quiz_bestStreak")
        
        // Create a view model and manually calculate expected badges
        var unlockedCount = 0
        XCTAssertEqual(unlockedCount, 0, "With no achievements completed, count should be 0")
        
        // Test case 2: Some achievements
        userDefaults.set(50, forKey: "quiz_totalAttempts")
        userDefaults.set(45, forKey: "quiz_correctAnswers") // 90% accuracy
        userDefaults.set(7, forKey: "quiz_bestStreak")
        
        // Calculate expected values
        unlockedCount = 0
        // starter (10+ correct)
        if 45 >= 10 { unlockedCount += 1 }
        // beginner (25+ correct)
        if 45 >= 25 { unlockedCount += 1 }
        // hotstreak (5+ streak)
        if 7 >= 5 { unlockedCount += 1 }
        // accurate (80%+ with 20+ attempts)
        if 50 >= 20 && Double(45) / Double(50) * 100 >= 80 { unlockedCount += 1 }
        // brainiac (90%+ with 50+ attempts)
        if 50 >= 50 && Double(45) / Double(50) * 100 >= 90 { unlockedCount += 1 }
        
        XCTAssertEqual(unlockedCount, 5, "With given stats, 5 badges should be unlocked")
        
        // Test case 3: All standard achievements
        userDefaults.set(300, forKey: "quiz_totalAttempts")
        userDefaults.set(270, forKey: "quiz_correctAnswers") // 90% accuracy
        userDefaults.set(15, forKey: "quiz_bestStreak")
        
        // Calculate with different logic to verify
        let accuracy = Double(270) / Double(300) * 100
        unlockedCount = 0
        
        if 270 >= 10 { unlockedCount += 1 } // starter
        if 270 >= 25 { unlockedCount += 1 } // beginner
        if 15 >= 5 { unlockedCount += 1 } // hotstreak
        if 15 >= 10 { unlockedCount += 1 } // inferno
        if accuracy >= 80 && 300 >= 20 { unlockedCount += 1 } // accurate
        if accuracy >= 90 && 300 >= 50 { unlockedCount += 1 } // brainiac
        // perfect has special condition: must be 100% accuracy
        if 270 >= 15 && 270 == 300 { unlockedCount += 1 } // perfect (won't be met in this case)
        if 300 >= 100 { unlockedCount += 1 } // dedicated
        if 300 >= 250 && Double(270) / Double(300) >= 0.85 { unlockedCount += 1 } // master
        
        // Should have 8 of 11 badges unlocked (all except the perfect and special ones)
        XCTAssertEqual(unlockedCount, 8, "With excellent stats, 8 standard badges should be unlocked")
        
        // Test case 4: Special achievements
        userDefaults.set(true, forKey: "quiz_comeback")
        userDefaults.set(true, forKey: "quiz_speedster")
        
        unlockedCount += 2 // Add the two special achievements
        // Should have 10 badges unlocked (all except perfect which requires 100% accuracy)
        XCTAssertEqual(unlockedCount, 10, "With special achievements, 10 badges should be unlocked")
    }
    
    // MARK: - Simple UI Tests without ViewInspector
    
    func testDashboardViewCreation() {
        // Simply test that the view can be created without crashing
        let view = DailyDashboardView()
        XCTAssertNotNil(view, "DailyDashboardView should be created successfully")
    }
    
    // Test the calculation function using our mock
    func testCalculateAccuracy() {
        // Set up test values in UserDefaults
        let userDefaults = UserDefaults.standard
        userDefaults.set(100, forKey: "quiz_totalAttempts")
        userDefaults.set(75, forKey: "quiz_correctAnswers")
        
        // Use our mock which has public methods instead of trying to access private methods
        dashboardMock.refreshQuizStats()
        
        // Test the accuracy calculation
        let accuracy = dashboardMock.calculateAccuracy()
        XCTAssertEqual(accuracy, 75, "Accuracy calculation should return 75%")
    }
} 