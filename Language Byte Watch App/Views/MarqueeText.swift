//
//  MarqueeText.swift
//  Language Byte Watch App
//
//  Created by Kai Wen on [2/10/2025].
//

import SwiftUI

// PreferenceKey to capture the rendered text width.
struct TextWidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

import SwiftUI

// PreferenceKey to capture the rendered text width.
//struct TextWidthPreferenceKey: PreferenceKey {
//    static var defaultValue: CGFloat = 0
//    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//        value = nextValue()
//    }
//}

struct MarqueeText: View {
    let text: String
    let font: Font
    let speed: Double
    let delay: Double
    let foregroundColor: Color
    let onLongPress: () -> Void  // Closure to handle long-press action
    
    let gap: CGFloat = 10

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    @State private var didStart: Bool = false

    var body: some View {
        ZStack {
            GeometryReader { geo in
                let containerW = geo.size.width
                Text(text)
                    .font(font)
                    .foregroundColor(foregroundColor)
                    .lineLimit(1)
                    .fixedSize()
                    .offset(x: xOffset)
                    .background(
                        GeometryReader { textGeo in
                            Color.clear
                                .preference(key: TextWidthPreferenceKey.self, value: textGeo.size.width)
                        }
                    )
                    .onPreferenceChange(TextWidthPreferenceKey.self) { measuredWidth in
                        textWidth = measuredWidth
                        containerWidth = containerW
                        if !didStart && containerWidth > 0 && textWidth > 0 {
                            didStart = true
                            startScrolling()
                        }
                    }
            }
            .clipped()
            .frame(height: 40)

            // Transparent overlay for gesture detection
            Rectangle()
                .foregroundColor(.clear)
                .contentShape(Rectangle()) // Ensures entire area is tappable
                .onLongPressGesture {
                    onLongPress() // Calls the action passed from ContentView
                }
        }
    }
    
    private func startScrolling() {
        xOffset = containerWidth
        let finalOffset = -(textWidth + gap)
        let totalDistance = containerWidth + textWidth + gap
        let duration = totalDistance / speed
        
        withAnimation(.linear(duration: duration)) {
            xOffset = finalOffset
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + delay) {
            startScrolling()
        }
    }
}
