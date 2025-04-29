import SwiftUI

/// A reusable language pair picker component for Apple Watch
/// 
/// This view displays a list of language pairs and allows the user
/// to select their preferred source and target languages.
/// Selections are automatically stored in AppStorage.
struct LanguagePicker: View {
    // Environment to allow dismissing the view
    @Environment(\.dismiss) private var dismiss
    
    // AppStorage for persisting selections
    @AppStorage("selectedSourceLanguage") private var sourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") private var targetLanguage: String = "es"
    
    // Optional closure to run after selection
    var onSelectionChanged: ((String, String) -> Void)?
    
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
            Section {
                ForEach(languagePairs, id: \.label) { pair in
                    Button(action: {
                        // Update stored languages
                        sourceLanguage = pair.source
                        targetLanguage = pair.target
                        
                        // Call the selection handler if provided
                        onSelectionChanged?(pair.source, pair.target)
                        
                        // Dismiss this view
                        dismiss()
                    }) {
                        HStack {
                            Text(pair.label)
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Show checkmark for current selection
                            if sourceLanguage == pair.source && 
                               targetLanguage == pair.target {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
            } header: {
                Text("Select Language Pair")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Languages")
    }
}

// Preview for design time
#Preview {
    NavigationStack {
        LanguagePicker { sourceCode, targetCode in
            print("Selected: \(sourceCode) → \(targetCode)")
        }
    }
}

// Extension to convert language codes to names
extension LanguagePicker {
    static func languageName(for code: String) -> String {
        switch code {
        case "en": return "English"
        case "es": return "Spanish"
        case "fr": return "French"
        case "de": return "German"
        case "it": return "Italian"
        case "ja": return "Japanese"
        case "zh": return "Chinese"
        default: return code.uppercased()
        }
    }
    
    static func currentLanguageLabel(source: String, target: String) -> String {
        return "\(languageName(for: source)) → \(languageName(for: target))"
    }
} 