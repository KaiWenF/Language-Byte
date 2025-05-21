import XCTest
import SwiftUI
@testable import Language_Byte_Watch_App

class AdaptiveMarqueeTextTests: XCTestCase {
    var shortText: String!
    var mediumText: String!
    var longText: String!
    
    override func setUp() {
        super.setUp()
        shortText = "Hello"
        mediumText = "This is a medium length text"
        longText = "This is a very long text that definitely needs to scroll with marquee effect because it won't fit in a small watch container"
    }
    
    override func tearDown() {
        shortText = nil
        mediumText = nil
        longText = nil
        super.tearDown()
    }
    
    func testTextWidthCalculation() {
        // Test with different fonts
        let titleFont = Font.title
        let bodyFont = Font.body
        let captionFont = Font.caption
        
        // Create mock text width calculator
        let calculator = MockTextWidthCalculator()
        
        // Test short text with different fonts
        XCTAssertEqual(calculator.calculateWidth(for: shortText, font: titleFont), 55, "Short text with title font should have correct width")
        XCTAssertEqual(calculator.calculateWidth(for: shortText, font: bodyFont), 45, "Short text with body font should have correct width")
        XCTAssertEqual(calculator.calculateWidth(for: shortText, font: captionFont), 35, "Short text with caption font should have correct width")
        
        // Test medium text
        XCTAssertEqual(calculator.calculateWidth(for: mediumText, font: bodyFont), 210, "Medium text should have correct width")
        
        // Test long text
        XCTAssertEqual(calculator.calculateWidth(for: longText, font: bodyFont), 560, "Long text should have correct width")
    }
    
    func testMarqueeNeedsAnimation() {
        // Create a mock marquee component
        let mockMarquee = MockAdaptiveMarquee()
        
        // Test with short text that fits
        mockMarquee.textWidth = 80
        mockMarquee.containerWidth = 100
        XCTAssertFalse(mockMarquee.needsMarquee, "Short text that fits should not need marquee")
        
        // Test with text that exactly fits
        mockMarquee.textWidth = 100
        mockMarquee.containerWidth = 100
        XCTAssertFalse(mockMarquee.needsMarquee, "Text that exactly fits should not need marquee")
        
        // Test with text slightly wider than container
        mockMarquee.textWidth = 101
        mockMarquee.containerWidth = 100
        XCTAssertTrue(mockMarquee.needsMarquee, "Text wider than container should need marquee")
        
        // Test with much wider text
        mockMarquee.textWidth = 200
        mockMarquee.containerWidth = 100
        XCTAssertTrue(mockMarquee.needsMarquee, "Much wider text should need marquee")
    }
    
    func testAnimationDuration() {
        // Create a mock marquee component
        let mockMarquee = MockAdaptiveMarquee()
        
        // Test short text animation (just above threshold)
        mockMarquee.textWidth = 110
        mockMarquee.containerWidth = 100
        mockMarquee.animationSpeed = 50
        XCTAssertEqual(mockMarquee.calculateAnimationDuration(), 0.2, accuracy: 0.01, "Short text animation duration should be correct")
        
        // Test medium text animation
        mockMarquee.textWidth = 200
        mockMarquee.containerWidth = 100
        XCTAssertEqual(mockMarquee.calculateAnimationDuration(), 2.0, accuracy: 0.01, "Medium text animation duration should be correct")
        
        // Test long text animation
        mockMarquee.textWidth = 500
        mockMarquee.containerWidth = 100
        XCTAssertEqual(mockMarquee.calculateAnimationDuration(), 8.0, accuracy: 0.01, "Long text animation duration should be correct")
        
        // Test with different speed settings
        mockMarquee.animationSpeed = 100 // Faster
        XCTAssertEqual(mockMarquee.calculateAnimationDuration(), 4.0, accuracy: 0.01, "Animation duration should adjust with speed")
        
        mockMarquee.animationSpeed = 25 // Slower
        XCTAssertEqual(mockMarquee.calculateAnimationDuration(), 16.0, accuracy: 0.01, "Animation duration should adjust with slower speed")
    }
    
    func testAnimationDelay() {
        // Create a mock marquee component
        let mockMarquee = MockAdaptiveMarquee()
        
        // Default delay
        XCTAssertEqual(mockMarquee.delay, 1.5, "Default delay should be set correctly")
        
        // Custom delay
        let customDelay = 3.0
        mockMarquee.delay = customDelay
        XCTAssertEqual(mockMarquee.delay, customDelay, "Custom delay should be set correctly")
    }
    
    func testTextTruncation() {
        // Create a mock marquee component that doesn't use animation
        let mockMarquee = MockAdaptiveMarquee()
        mockMarquee.useMarqueeAnimation = false
        
        // Test with text that fits
        mockMarquee.text = shortText
        mockMarquee.textWidth = 80
        mockMarquee.containerWidth = 100
        XCTAssertEqual(mockMarquee.displayText(), shortText, "Text that fits should not be truncated")
        
        // Test with text that doesn't fit
        mockMarquee.text = longText
        mockMarquee.textWidth = 500
        mockMarquee.containerWidth = 100
        let truncatedText = mockMarquee.displayText()
        XCTAssertNotEqual(truncatedText, longText, "Long text should be truncated")
        XCTAssertTrue(truncatedText.hasSuffix("..."), "Truncated text should end with ellipsis")
        XCTAssertTrue(truncatedText.count < longText.count, "Truncated text should be shorter than original")
    }
    
    func testResetAnimation() {
        // Create a mock marquee component
        let mockMarquee = MockAdaptiveMarquee()
        
        // Configure with animated text
        mockMarquee.textWidth = 200
        mockMarquee.containerWidth = 100
        mockMarquee.hasStartedAnimation = true
        mockMarquee.currentOffset = -50
        
        // Reset animation
        mockMarquee.resetAnimation()
        
        // Verify reset state
        XCTAssertFalse(mockMarquee.hasStartedAnimation, "Animation started flag should be reset")
        XCTAssertEqual(mockMarquee.currentOffset, 0, "Animation offset should be reset to 0")
    }
}

// MARK: - Mock Classes

class MockTextWidthCalculator {
    func calculateWidth(for text: String, font: Font) -> CGFloat {
        // Simplified width calculation for testing
        var fontMultiplier: CGFloat
        
        switch font {
        case Font.title, Font.title2, Font.title3:
            fontMultiplier = 11.0
        case Font.body:
            fontMultiplier = 9.0
        case Font.caption, Font.caption2:
            fontMultiplier = 7.0
        default:
            fontMultiplier = 8.0
        }
        
        return CGFloat(text.count) * fontMultiplier
    }
}

class MockAdaptiveMarquee {
    var text: String = ""
    var textWidth: CGFloat = 0
    var containerWidth: CGFloat = 0
    var animationSpeed: CGFloat = 50
    var delay: TimeInterval = 1.5
    var useMarqueeAnimation = true
    var hasStartedAnimation = false
    var currentOffset: CGFloat = 0
    
    var needsMarquee: Bool {
        return textWidth > containerWidth
    }
    
    func calculateAnimationDuration() -> TimeInterval {
        guard needsMarquee else { return 0 }
        
        // Calculate how far the text needs to move
        let distance = textWidth - containerWidth
        
        // Calculate duration based on distance and speed
        // Higher speed = shorter duration
        return TimeInterval(distance / animationSpeed)
    }
    
    func displayText() -> String {
        if useMarqueeAnimation || textWidth <= containerWidth {
            return text
        } else {
            // Simplified truncation for testing
            let charactersToKeep = Int(containerWidth / (textWidth / CGFloat(text.count))) - 3
            if charactersToKeep < text.count {
                let index = text.index(text.startIndex, offsetBy: max(0, charactersToKeep))
                return String(text[..<index]) + "..."
            }
            return text
        }
    }
    
    func resetAnimation() {
        hasStartedAnimation = false
        currentOffset = 0
    }
} 