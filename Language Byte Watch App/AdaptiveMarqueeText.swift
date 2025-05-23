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
    
    // This offset moves left when scrolling
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { containerGeo in
            ZStack(alignment: .leading) {
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .onAppear {
                                    // Measure the text and container once this subview appears
                                    textWidth = textGeo.size.width
                                    containerWidth = containerGeo.size.width
                                    startOrStopScrolling()
                                }
                        }
                    )
                    .offset(x: xOffset)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .clipped()
            .onChange(of: containerGeo.size.width) { newWidth in
                // If user rotates the watch or container changes,
                // re-measure and decide if we should scroll again.
                containerWidth = newWidth
                startOrStopScrolling()
            }
            .onChange(of: text) { _ in
                // Recalculate when text changes
                DispatchQueue.main.async {
                    startOrStopScrolling()
                }
            }
        }
        .frame(height: 40) // Adjust for your design
    }
    
    /// Cancels scrolling if text fits, or starts a new scroll if text is too wide.
    private func startOrStopScrolling() {
        // If text fits within container, center it and don't scroll
        guard textWidth > containerWidth else {
            withAnimation(.none) {
                xOffset = 0  // Start at left edge for all text
            }
            return
        }
        
        // For text that needs scrolling
        
        // First, reset to initial position (visible at left edge)
        withAnimation(.none) {
            xOffset = 0
        }
        
        // Calculate reasonable scroll time based on text length
        let scrollDuration = Double(textWidth) / speed
        
        // Delayed start to make sure text is visible first
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(
                Animation.linear(duration: scrollDuration)
                    .delay(0.5)
                    .repeatForever(autoreverses: true)
            ) {
                // Scroll to position where end of text is just visible
                let scrollAmount = min(textWidth - containerWidth, max(0, textWidth - containerWidth + 10))
                xOffset = -scrollAmount
            }
        }
    }
}
