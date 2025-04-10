//
//  ContentView.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [02/10/2025].
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WordViewModel()
    @State private var shouldScroll = false
    @State private var showSettings = false  // ✅ Track when Settings should be displayed
    @AppStorage("favoriteColor") private var favoriteColor: String = "yellow"

    var body: some View {
        NavigationStack {  // ✅ Wrap in NavigationStack
            VStack {
                Text("Language Byte")
                    .font(.headline)
                    .padding(.top, 8)

                ZStack {
                    if shouldScroll {
                        MarqueeText(
                            text: viewModel.displayWord,
                            font: .system(size: 32, weight: .bold),
                            speed: 50,
                            delay: 1,
                            foregroundColor: viewModel.isCurrentWordFavorite ? colorFromString(favoriteColor) : .white,
                            onLongPress: {
                                viewModel.toggleFavorite()
                            }
                        )
                        .frame(height: 40)
                        .padding()
                    } else {
                        Text(viewModel.displayWord)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(viewModel.isCurrentWordFavorite ? colorFromString(favoriteColor) : .white)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding()
                            .onLongPressGesture {
                                viewModel.toggleFavorite()
                            }
                    }
                }
                .frame(width: 150, height: 40) // Adjust for watch screen
                .onAppear { checkIfShouldScroll() }
                .onChange(of: viewModel.displayWord) { _ in checkIfShouldScroll() }

                // ✅ CATEGORY PICKER
                Picker("Category", selection: $viewModel.selectedCategory) {
                    ForEach(viewModel.availableCategories, id: \.self) { cat in
                        Text(cat.capitalized).tag(cat)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 60)
                .onChange(of: viewModel.selectedCategory) { newCategory in
                    if newCategory == "⚙️ Settings" {
                        showSettings = true  // ✅ Open Settings screen
                    } else {
                        viewModel.pickRandomWord()
                    }
                }

                // ✅ Navigation Link to Settings
                .navigationDestination(isPresented: $showSettings) {
                    SettingsView().environmentObject(viewModel)
                }
                .onChange(of: showSettings) { isShowing in
                    if isShowing {
                        viewModel.stopSpeaking()  // ✅ Stop any currently queued speech
                    } else {
                        viewModel.stopSpeaking()  // ✅ Stop any speaking after returning
                        viewModel.preventNextSpeak = true  // ✅ Prevent next word from speaking
                        viewModel.selectedCategory = "all"  // ✅ Reset category to "All"
                    }
                }

                // BUTTONS
                HStack {
                    Button("Toggle") {
                        viewModel.toggleDisplay()
                    }
                    .buttonStyle(.bordered)

                    Button("New Word") {
                        viewModel.pickRandomWord()  // ✅ Now correctly selects a new word AND speaks it
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.bottom, 8)
            }
            .padding()
            .onAppear { viewModel.loadWords() }
        }
    }

    // Check if text should scroll (only for long words)
    private func checkIfShouldScroll() {
        shouldScroll = measureTextWidth(viewModel.displayWord) > 150
    }

    // Measure the actual text width
    private func measureTextWidth(_ text: String) -> CGFloat {
        let font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return (text as NSString).size(withAttributes: [.font: font]).width
    }
}


// This is optional, used for Xcode previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

