//
//  LanguageSelectionView.swift
//  Language Byte Watch App
//
//  Created by [Kai Wen] on [2/10/2025].
//

import SwiftUI

struct LanguageSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: WordViewModel
    
    // Store language selections in AppStorage
    @AppStorage("selectedSourceLanguage") private var selectedSourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") private var selectedTargetLanguage: String = "es"
    
    // Available language pairs
    private let languagePairs: [(source: String, target: String, label: String)] = [
        ("en", "es", "English → Spanish"),
        ("en", "fr", "English → French"),
        ("en", "de", "English → German"),
        ("en", "it", "English → Italian"),
        ("en", "ja", "English → Japanese"),
        ("en", "zh", "English → Chinese")
    ]
    
    var body: some View {
        List {
            Section(header: Text("Select Language")) {
                // Use only the static language pairs for now
                ForEach(languagePairs, id: \.label) { pair in
                    Button(action: {
                        // Save selected languages with AppStorage
                        selectedSourceLanguage = pair.source
                        selectedTargetLanguage = pair.target
                        
                        // Also update the view model with the selection
                        if let matchingPair = viewModel.availableLanguagePairs.first(where: { 
                            $0.sourceLanguage.code == pair.source && 
                            $0.targetLanguage.code == pair.target 
                        }) {
                            viewModel.selectLanguagePair(matchingPair)
                        }
                        
                        dismiss()
                    }) {
                        HStack {
                            Text(pair.label)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Show checkmark for current selection
                            if selectedSourceLanguage == pair.source && 
                               selectedTargetLanguage == pair.target {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Languages")
        .onAppear {
            // Ensure the view model has loaded language data
            if viewModel.availableLanguagePairs.isEmpty {
                viewModel.loadLanguageData()
            }
        }
    }
}

// Preview with MockWordViewModel
#Preview {
    NavigationStack {
        LanguageSelectionView()
            .environmentObject(WordViewModel())
    }
} 