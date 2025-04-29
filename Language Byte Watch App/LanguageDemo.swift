import SwiftUI

/// A demo view showing how to use the LanguagePicker
struct LanguageDemoView: View {
    // Access the stored language selections
    @AppStorage("selectedSourceLanguage") private var sourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") private var targetLanguage: String = "es"
    
    // State to control navigation
    @State private var showLanguagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Display current language selection
                VStack {
                    Text("Current Language Pair")
                        .font(.headline)
                    
                    Text(LanguagePicker.currentLanguageLabel(source: sourceLanguage, target: targetLanguage))
                        .font(.body)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                // Button to change language
                Button(action: {
                    showLanguagePicker = true
                }) {
                    HStack {
                        Image(systemName: "globe")
                        Text("Change Language")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                
                Spacer()
                
                // Information text
                Text("Language selections are automatically stored in AppStorage and persisted between app launches.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .navigationTitle("Language Demo")
            .navigationDestination(isPresented: $showLanguagePicker) {
                LanguagePicker { newSource, newTarget in
                    print("Selected new language pair: \(newSource) → \(newTarget)")
                    // Any additional logic after selection can go here
                }
            }
        }
    }
}

// Preview for design time
#Preview {
    LanguageDemoView()
} 