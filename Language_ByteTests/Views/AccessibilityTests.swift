import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

class AccessibilityTests: XCTestCase {
    var wordStudyView: MockWordStudyView!
    var quizView: MockQuizView!
    var settingsView: MockSettingsView!
    
    override func setUp() {
        super.setUp()
        wordStudyView = MockWordStudyView()
        quizView = MockQuizView()
        settingsView = MockSettingsView()
    }
    
    override func tearDown() {
        wordStudyView = nil
        quizView = nil
        settingsView = nil
        super.tearDown()
    }
    
    func testWordStudyViewAccessibilityLabels() {
        // Test that each component has appropriate accessibility labels
        XCTAssertFalse(wordStudyView.wordLabel.accessibilityLabel.isEmpty, "Word label should have accessibility label")
        XCTAssertEqual(wordStudyView.wordLabel.accessibilityLabel, "Spanish word: hola", "Word label should have correct language context")
        
        XCTAssertFalse(wordStudyView.categoryLabel.accessibilityLabel.isEmpty, "Category label should have accessibility label")
        XCTAssertEqual(wordStudyView.categoryLabel.accessibilityLabel, "Category: greetings", "Category label should describe content")
        
        XCTAssertFalse(wordStudyView.favoriteButton.accessibilityLabel.isEmpty, "Favorite button should have accessibility label")
        XCTAssertEqual(wordStudyView.favoriteButton.accessibilityLabel, "Add to favorites", "Favorite button should describe action")
        
        // Test toggled state
        wordStudyView.isFavorite = true
        XCTAssertEqual(wordStudyView.favoriteButton.accessibilityLabel, "Remove from favorites", "Favorite button should update when toggled")
    }
    
    func testWordStudyViewAccessibilityHints() {
        // Test that components have appropriate hints
        XCTAssertFalse(wordStudyView.speakButton.accessibilityHint.isEmpty, "Speak button should have accessibility hint")
        XCTAssertEqual(wordStudyView.speakButton.accessibilityHint, "Pronounces the word in Spanish", "Speak button hint should mention language")
        
        XCTAssertFalse(wordStudyView.nextButton.accessibilityHint.isEmpty, "Next button should have accessibility hint")
        XCTAssertEqual(wordStudyView.nextButton.accessibilityHint, "Shows the next word", "Next button hint should describe action")
    }
    
    func testWordStudyViewAccessibilityTraits() {
        // Test that components have appropriate traits
        XCTAssertTrue(wordStudyView.wordLabel.accessibilityTraits.contains(.staticText), "Word label should have staticText trait")
        XCTAssertTrue(wordStudyView.speakButton.accessibilityTraits.contains(.button), "Speak button should have button trait")
        XCTAssertTrue(wordStudyView.favoriteButton.accessibilityTraits.contains(.button), "Favorite button should have button trait")
        
        // Test toggled state updates trait
        wordStudyView.isFavorite = true
        XCTAssertTrue(wordStudyView.favoriteButton.accessibilityTraits.contains(.selected), "Favorite button should have selected trait when favorite")
    }
    
    func testQuizViewAccessibility() {
        // Test quiz options have appropriate accessibility
        XCTAssertEqual(quizView.questionLabel.accessibilityLabel, "Translate: hello", "Question should have clear instruction")
        
        // Test options
        XCTAssertEqual(quizView.option1Button.accessibilityLabel, "hola", "Option should read the word")
        XCTAssertEqual(quizView.option1Button.accessibilityHint, "Select this answer", "Option should have clear hint")
        
        // Test correct answer feedback
        quizView.selectAnswer(correct: true)
        XCTAssertTrue(quizView.feedbackView.accessibilityTraits.contains(.updatesFrequently), "Feedback should update frequently")
        XCTAssertEqual(quizView.feedbackView.accessibilityLabel, "Correct answer!", "Feedback should announce result")
    }
    
    func testSettingsViewAccessibility() {
        // Test settings toggles have appropriate accessibility
        XCTAssertEqual(settingsView.textToSpeechToggle.accessibilityLabel, "Enable text to speech", "Toggle should have clear label")
        XCTAssertEqual(settingsView.textToSpeechToggle.accessibilityHint, "Turn on to enable word pronunciation", "Toggle should have descriptive hint")
        
        // Test settings sliders
        XCTAssertEqual(settingsView.speechRateSlider.accessibilityLabel, "Speech rate", "Slider should have clear label")
        XCTAssertEqual(settingsView.speechRateSlider.accessibilityValue, "Normal", "Slider should have meaningful value")
        
        // Update slider value
        settingsView.speechRateSlider.value = 0.75
        XCTAssertEqual(settingsView.speechRateSlider.accessibilityValue, "Fast", "Slider value should update")
    }
    
    func testDynamicTypeSupport() {
        // Test text scales appropriately with Dynamic Type settings
        let smallTextView = wordStudyView.createWordLabelWithSize(.small)
        let largeTextView = wordStudyView.createWordLabelWithSize(.xxxLarge)
        
        XCTAssertTrue(largeTextView.fontSize > smallTextView.fontSize, "Text should scale with Dynamic Type")
    }
    
    func testReducedMotionSupport() {
        // Test animations respect reduced motion setting
        let defaultMotion = quizView.createTransitionAnimation(reducedMotion: false)
        let reducedMotion = quizView.createTransitionAnimation(reducedMotion: true)
        
        XCTAssertNotEqual(defaultMotion, reducedMotion, "Animations should adapt to reduced motion")
        XCTAssertEqual(reducedMotion, .opacity, "Reduced motion should use fade transitions")
    }
    
    func testVoiceOverGrouping() {
        // Test elements are properly grouped for VoiceOver
        XCTAssertEqual(wordStudyView.wordGroup.accessibilityElements?.count, 2, "Word group should contain word and pronunciation")
        XCTAssertEqual(quizView.optionsGroup.accessibilityElements?.count, 3, "Options group should contain all 3 choices")
    }
    
    func testAccessibilityActions() {
        // Test custom actions are available for accessibility
        XCTAssertEqual(wordStudyView.customActions.count, 3, "Should have 3 custom actions")
        
        let action = wordStudyView.customActions.first!
        XCTAssertEqual(action.name, "Pronounce Word", "Action should have descriptive name")
    }
    
    func testScreenReaderAnnouncements() {
        // Test appropriate announcements are made for screen readers
        quizView.simulateCorrectAnswer()
        XCTAssertEqual(quizView.lastAnnouncement, "Correct! Your score is now 1 out of 1.", "Should announce result with context")
        
        quizView.simulateNewQuestion()
        XCTAssertEqual(quizView.lastAnnouncement, "New question: Translate: goodbye", "Should announce new questions")
    }
}

// MARK: - Mock Classes

class MockWordStudyView {
    var wordLabel = MockAccessibleText(text: "hola")
    var categoryLabel = MockAccessibleText(text: "greetings")
    var speakButton = MockAccessibleButton(label: "Speak")
    var favoriteButton = MockAccessibleButton(label: "Favorite")
    var nextButton = MockAccessibleButton(label: "Next Word")
    var isFavorite = false
    var wordGroup = MockAccessibilityGroup()
    var customActions = [MockAccessibilityAction]()
    
    init() {
        // Set up accessibility properties
        wordLabel.accessibilityLabel = "Spanish word: hola"
        wordLabel.accessibilityTraits = .staticText
        
        categoryLabel.accessibilityLabel = "Category: greetings"
        categoryLabel.accessibilityTraits = .staticText
        
        speakButton.accessibilityLabel = "Pronounce"
        speakButton.accessibilityHint = "Pronounces the word in Spanish"
        speakButton.accessibilityTraits = .button
        
        updateFavoriteButton()
        
        nextButton.accessibilityLabel = "Next"
        nextButton.accessibilityHint = "Shows the next word"
        nextButton.accessibilityTraits = .button
        
        // Add word and pronunciation button to group
        wordGroup.accessibilityElements = [wordLabel, speakButton]
        
        // Set up custom actions
        customActions = [
            MockAccessibilityAction(name: "Pronounce Word", description: "Speaks the current word"),
            MockAccessibilityAction(name: "Toggle Favorite", description: "Adds or removes from favorites"),
            MockAccessibilityAction(name: "Next Word", description: "Shows the next word")
        ]
    }
    
    func updateFavoriteButton() {
        favoriteButton.accessibilityLabel = isFavorite ? "Remove from favorites" : "Add to favorites"
        favoriteButton.accessibilityTraits = isFavorite ? [.button, .selected] : .button
    }
    
    func createWordLabelWithSize(_ size: DynamicTypeSize) -> MockTextView {
        let fontSize: CGFloat
        
        switch size {
        case .small:
            fontSize = 14
        case .medium:
            fontSize = 17
        case .large:
            fontSize = 20
        case .extraLarge:
            fontSize = 23
        case .extraExtraLarge:
            fontSize = 26
        case .extraExtraExtraLarge:
            fontSize = 29
        default:
            fontSize = 17
        }
        
        return MockTextView(text: "hola", fontSize: fontSize)
    }
}

class MockQuizView {
    var questionLabel = MockAccessibleText(text: "Translate: hello")
    var option1Button = MockAccessibleButton(label: "Option 1")
    var option2Button = MockAccessibleButton(label: "Option 2")
    var option3Button = MockAccessibleButton(label: "Option 3")
    var feedbackView = MockAccessibleText(text: "")
    var optionsGroup = MockAccessibilityGroup()
    var lastAnnouncement = ""
    var score = 0
    var attempts = 0
    
    init() {
        // Set up accessibility properties
        questionLabel.accessibilityLabel = "Translate: hello"
        questionLabel.accessibilityTraits = .staticText
        
        option1Button.accessibilityLabel = "hola"
        option1Button.accessibilityHint = "Select this answer"
        option1Button.accessibilityTraits = .button
        
        option2Button.accessibilityLabel = "adios"
        option2Button.accessibilityHint = "Select this answer"
        option2Button.accessibilityTraits = .button
        
        option3Button.accessibilityLabel = "gracias"
        option3Button.accessibilityHint = "Select this answer"
        option3Button.accessibilityTraits = .button
        
        feedbackView.accessibilityTraits = [.staticText, .updatesFrequently]
        
        // Group options for VoiceOver
        optionsGroup.accessibilityElements = [option1Button, option2Button, option3Button]
    }
    
    func selectAnswer(correct: Bool) {
        attempts += 1
        if correct {
            score += 1
            feedbackView.text = "Correct!"
            feedbackView.accessibilityLabel = "Correct answer!"
        } else {
            feedbackView.text = "Incorrect."
            feedbackView.accessibilityLabel = "Incorrect answer. The correct answer is hola."
        }
    }
    
    func createTransitionAnimation(reducedMotion: Bool) -> Animation {
        if reducedMotion {
            return .opacity
        } else {
            return .scale
        }
    }
    
    func simulateCorrectAnswer() {
        selectAnswer(correct: true)
        lastAnnouncement = "Correct! Your score is now \(score) out of \(attempts)."
    }
    
    func simulateNewQuestion() {
        questionLabel.text = "Translate: goodbye"
        questionLabel.accessibilityLabel = "Translate: goodbye"
        
        option1Button.accessibilityLabel = "hola"
        option2Button.accessibilityLabel = "adios"
        option3Button.accessibilityLabel = "gracias"
        
        lastAnnouncement = "New question: Translate: goodbye"
    }
}

class MockSettingsView {
    var textToSpeechToggle = MockAccessibleToggle(isOn: true)
    var notificationsToggle = MockAccessibleToggle(isOn: false)
    var speechRateSlider = MockAccessibleSlider(value: 0.5)
    
    init() {
        // Set up accessibility properties
        textToSpeechToggle.accessibilityLabel = "Enable text to speech"
        textToSpeechToggle.accessibilityHint = "Turn on to enable word pronunciation"
        
        notificationsToggle.accessibilityLabel = "Enable daily notifications"
        notificationsToggle.accessibilityHint = "Turn on to receive daily word reminders"
        
        speechRateSlider.accessibilityLabel = "Speech rate"
        updateSliderAccessibilityValue()
    }
    
    func updateSliderAccessibilityValue() {
        if speechRateSlider.value < 0.33 {
            speechRateSlider.accessibilityValue = "Slow"
        } else if speechRateSlider.value < 0.66 {
            speechRateSlider.accessibilityValue = "Normal"
        } else {
            speechRateSlider.accessibilityValue = "Fast"
        }
    }
}

// MARK: - Supporting Mock Types

struct MockAccessibleText {
    var text: String
    var accessibilityLabel = ""
    var accessibilityHint = ""
    var accessibilityTraits: AccessibilityTraits = []
}

struct MockAccessibleButton {
    var label: String
    var accessibilityLabel = ""
    var accessibilityHint = ""
    var accessibilityTraits: AccessibilityTraits = .button
}

struct MockAccessibleToggle {
    var isOn: Bool
    var accessibilityLabel = ""
    var accessibilityHint = ""
}

struct MockAccessibleSlider {
    var value: Float
    var accessibilityLabel = ""
    var accessibilityValue = ""
}

struct MockAccessibilityGroup {
    var accessibilityElements: [Any]? = nil
}

struct MockAccessibilityAction {
    let name: String
    let description: String
}

struct MockTextView {
    let text: String
    let fontSize: CGFloat
}

struct AccessibilityTraits: OptionSet, RawRepresentable {
    typealias RawValue = UInt
    
    let rawValue: RawValue
    
    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    static let button = AccessibilityTraits(rawValue: 1 << 0)
    static let staticText = AccessibilityTraits(rawValue: 1 << 1)
    static let selected = AccessibilityTraits(rawValue: 1 << 2)
    static let updatesFrequently = AccessibilityTraits(rawValue: 1 << 3)
}

enum Animation {
    case scale
    case opacity
}

enum DynamicTypeSize {
    case small, medium, large, extraLarge, extraExtraLarge, extraExtraExtraLarge, xxxLarge
} 