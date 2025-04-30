import Testing
import SwiftUI
@testable import Language_Byte

struct QuizViewTests {
    
    // Test the basic UI elements of QuizView
    @Test func testQuizViewBasicUI() async throws {
        // Setup
        let quizView = QuizView()
        
        // Reset stored values before test
        UserDefaults.standard.set(0, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(0, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(0, forKey: "quiz_bestStreak")
        
        // Verify basic UI elements are present
        #expect(try await ViewInspector.inspect(quizView).find(ViewType.HStack.self).find(ViewType.Text.self).string().contains("Quiz Mode"))
        
        // Test that score display is present and shows 0/0 initially
        let scoreText = try await ViewInspector.inspect(quizView).find(textWithString: "0/0")
        #expect(scoreText != nil, "Score display should be visible")
    }
    
    // Test the exit confirmation functionality
    @Test func testExitConfirmation() async throws {
        // Setup
        let quizView = QuizView()
        
        // Initially the confirmation dialog should not be shown
        #expect(quizView.showExitConfirmation == false)
        
        // Simulate tapping the back button
        await quizView.showExitConfirmation = true
        
        // Now the confirmation dialog should be visible
        #expect(quizView.showExitConfirmation == true)
        
        // Test that resetQuiz clears the state appropriately
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        quizView.showFeedback = true
        quizView.selectedChoice = "hola"
        
        // Call resetQuiz
        await quizView.resetQuiz()
        
        // Verify state is reset
        #expect(quizView.showFeedback == false)
        #expect(quizView.selectedChoice == "")
        #expect(quizView.currentQuestion == nil)
    }
    
    // Test the feedback visualization
    @Test func testFeedbackVisualization() async throws {
        // Setup
        let quizView = QuizView()
        quizView.currentQuestion = QuizQuestion(
            sourceWord: "hello",
            correctAnswer: "hola",
            choices: ["hola", "adiós", "gracias"]
        )
        
        // Initially, no buttons should have tint
        for choice in quizView.currentQuestion!.choices {
            let button = try await ViewInspector.inspect(quizView)
                .find(buttonWithLabel: choice)
            
            #expect(button.tint == nil, "Button should not have tint initially")
        }
        
        // Simulate a correct answer
        quizView.selectedChoice = "hola"
        quizView.isCorrect = true
        quizView.showFeedback = true
        
        // The selected button should now have green tint
        let correctButton = try await ViewInspector.inspect(quizView)
            .find(buttonWithLabel: "hola")
        
        #expect(correctButton.tint == .green, "Correct button should have green tint")
        
        // Reset and simulate an incorrect answer
        quizView.showFeedback = false
        quizView.selectedChoice = "adiós"
        quizView.isCorrect = false
        quizView.showFeedback = true
        
        // The selected button should now have red tint
        let incorrectButton = try await ViewInspector.inspect(quizView)
            .find(buttonWithLabel: "adiós")
        
        #expect(incorrectButton.tint == .red, "Incorrect button should have red tint")
    }
    
    // Test the presentation of QuizStatsView from DailyDashboardView
    @Test func testQuizStatsNavigation() async throws {
        // Setup
        let dashboardView = DailyDashboardView()
        
        // Initially, showQuizStats should be false
        #expect(dashboardView.showQuizStats == false)
        
        // Find and tap the "View Quiz Stats" button
        let statsButton = try await ViewInspector.inspect(dashboardView)
            .find(buttonWithText: "View Quiz Stats")
        
        await statsButton.tap()
        
        // Now showQuizStats should be true
        #expect(dashboardView.showQuizStats == true)
        
        // Verify navigation destination is QuizStatsView
        let destination = try await ViewInspector.inspect(dashboardView)
            .navigationDestination(isPresented: dashboardView.$showQuizStats)
        
        #expect(destination.view is QuizStatsView, "Destination should be QuizStatsView")
    }
} 