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
            .clipped()
            .onChange(of: containerGeo.size.width) { newWidth in
                // If user rotates the watch or container changes,
                // re-measure and decide if we should scroll again.
                containerWidth = newWidth
                startOrStopScrolling()
            }
        }
        .frame(height: 40) // Adjust for your design
    }
    
    /// Cancels scrolling if text fits, or starts a new scroll if text is too wide.
    private func startOrStopScrolling() {
        // Immediately stop any existing animation
        withAnimation(.none) {
            xOffset = 0
        }
        
        // If text fits within container, no scrolling needed
        guard textWidth > containerWidth else {
            return
        }
        
        // Otherwise, text is too big: start scrolling
        let distance = textWidth + containerWidth
        let duration = distance / speed
        
        withAnimation(
            Animation.linear(duration: duration)
                .delay(delay)
                .repeatForever(autoreverses: false)
        ) {
            xOffset = -distance
        }
    }
}
