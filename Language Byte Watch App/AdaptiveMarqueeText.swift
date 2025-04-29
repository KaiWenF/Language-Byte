//
//  AdaptiveMarqueeText.swift
//  Language Byte
//
//  Created by Kevin Franklin on 2/10/25.
//
import SwiftUI

/// Displays text normally if it fits. If it's too wide, it scrolls (marquee).
struct AdaptiveMarqueeText: View {
    let text: String
    let font: Font
    let speed: Double    // points per second
    let delay: Double    // seconds before scrolling starts
    
    // Initialize with optional delay
    init(text: String, font: Font, speed: Double, delay: Double = 1.0) {
        self.text = text
        self.font = font
        self.speed = speed
        self.delay = delay
    }
    
    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var shouldScroll: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if shouldScroll {
                    // For text that needs scrolling - simplified direct approach
                    let scrollableText = Text(text)
                        .font(font)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                    
                    scrollableText
                        .modifier(AdaptiveScrollingModifier(
                            textWidth: textWidth,
                            containerWidth: containerWidth,
                            speed: speed,
                            delay: delay
                        ))
                        .id(text)
                        .onAppear {
                            print("Scrolling text: \(text), width: \(textWidth), container: \(containerWidth)")
                        }
                } else {
                    // For text that fits within container
                    Text(text)
                        .font(font)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .background(
                // Use this technique for measuring text width in SwiftUI
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .hidden()
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .onAppear {
                                    let measuredWidth = textGeometry.size.width
                                    let currentContainerWidth = geometry.size.width
                                    // Update state only if measurements changed significantly
                                    if abs(measuredWidth - textWidth) > 1 || abs(currentContainerWidth - containerWidth) > 1 {
                                        textWidth = measuredWidth
                                        containerWidth = currentContainerWidth
                                        // Calculate shouldScroll HERE, after measurement
                                        shouldScroll = textWidth > (containerWidth - 10)
                                        print("Text measured: \(text), width: \(textWidth), container: \(containerWidth), should scroll: \(shouldScroll)")
                                    }
                                }
                        }
                    )
            )
            .onChange(of: text) { _ in
                // Text changed, re-evaluating scroll state will happen naturally
                // because the view with .id(text) gets recreated, triggering measurement.
                // We don't need to calculate shouldScroll here with potentially old width.
                print("Text changed to: \(text)")
            }
            .onChange(of: geometry.size.width) { newWidth in
                containerWidth = newWidth
                shouldScroll = textWidth > (containerWidth - 10)
            }
        }
        .clipped()          // Ensure text is clipped to container bounds
        .frame(height: 40)
    }
}

// A modifier that handles the scrolling animation
struct AdaptiveScrollingModifier: ViewModifier {
    let textWidth: CGFloat
    let containerWidth: CGFloat
    let speed: Double
    let delay: Double
    
    @State private var animating = false
    @State private var animationID = UUID() // Add ID to force animation reset
    
    func body(content: Content) -> some View {
        content
            .offset(x: animating ? -textWidth : containerWidth)
            .onAppear {
                startAnimation()
            }
            .onChange(of: textWidth) { _ in resetAnimation() }
            .onChange(of: containerWidth) { _ in resetAnimation() }
    }
    
    private func resetAnimation() {
        animating = false // Stop current animation
        animationID = UUID() // Change ID to break the previous animation chain
        startAnimation()     // Start new animation
    }
    
    private func startAnimation() {
        // Ensure we don't start if widths are zero
        guard textWidth > 0, containerWidth > 0, speed > 0 else { return }
        
        let currentID = animationID
        // Initial delay then start animation
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            // Only proceed if the animation ID hasn't changed (i.e., not reset)
            guard currentID == animationID else { return }
            
            let totalDistance = textWidth + containerWidth
            // Avoid division by zero if speed is somehow 0
            let duration = totalDistance / max(speed, 1)
            
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                animating = true
            }
        }
    }
}
