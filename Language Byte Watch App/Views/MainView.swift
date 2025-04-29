import SwiftUI
import AVFoundation

struct MainView: View {
    @StateObject private var viewModel = WordViewModel()
    @AppStorage("selectedSourceLanguage") private var sourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") private var targetLanguage: String = "es"
    @State private var showLanguageSelection = false
    
    // Function to get display name for language code
    private func languageName(for code: String) -> String {
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
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // App title
                    Text("Language Byte")
                        .font(.headline)
                        .padding(.top, 30)
                    
                    // Current language selector
                    Button(action: {
                        showLanguageSelection = true
                    }) {
                        VStack(spacing: 4) {
                            HStack(spacing: 10) {
                                Text(languageName(for: sourceLanguage))
                                    .fontWeight(.medium)
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                
                                Text(languageName(for: targetLanguage))
                                    .fontWeight(.medium)
                            }
                            
                            // Small indicator that this is tappable
                            Text("Tap to change")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    // Remove the Spacer and add a small fixed-height spacer instead
                    Spacer(minLength: 4)
                    
                    // Start studying button
                    NavigationLink(destination: WordStudyView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Studying")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.bottom, 10)
                    
                    // Favorite Words button
                    NavigationLink(destination: FavoritesView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "star.fill")
                            Text("Favorite Words")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .padding(.bottom, 10)
                    
                    // Daily Dashboard button
                    NavigationLink(destination: DailyDashboardView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                            Text("Daily Dashboard")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    .padding(.bottom, 10)
                    
                    // Settings button
                    NavigationLink(destination: SettingsView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "gear")
                            Text("Settings")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 10)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showLanguageSelection) {
                LanguageSelectionView().environmentObject(viewModel)
            }
            .onAppear {
                viewModel.loadLanguageData()
            }
        }
    }
}

#Preview {
    MainView()
} 
