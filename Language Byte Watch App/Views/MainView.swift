import SwiftUI
import AVFoundation

// Import necessary view models and managers
import class Language_Byte_Watch_App.WordViewModel
import class Language_Byte_Watch_App.PremiumAccessManager

// Import views
import struct Language_Byte_Watch_App.DailyDashboardView
import struct Language_Byte_Watch_App.CategorySelectionView
import struct Language_Byte_Watch_App.WordStudyView
import struct Language_Byte_Watch_App.FavoritesView
import struct Language_Byte_Watch_App.QuizView
import struct Language_Byte_Watch_App.WeeklyReviewView
import struct Language_Byte_Watch_App.SettingsView
import struct Language_Byte_Watch_App.LanguageSelectionView

// Import modifiers
import struct Language_Byte_Watch_App.PremiumFeatureModifier
import enum Language_Byte_Watch_App.PremiumFeature

struct MainView: View {
    @StateObject private var viewModel = WordViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @AppStorage("selectedSourceLanguage") private var sourceLanguage: String = "en"
    @AppStorage("selectedTargetLanguage") private var targetLanguage: String = "es"
    @State private var showLanguageSelection = false
    @State private var showCategorySelection = false
    @State private var showPaywall = false
    @State private var selectedPremiumFeature: PremiumFeature?
    
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
        case "ko": return "Korean"
        case "ht": return "Haitian Creole"
        case "pt": return "Portuguese"
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
                        if premiumManager.isFeatureAvailable(.multipleLanguages) {
                            showLanguageSelection = true
                        } else {
                            selectedPremiumFeature = .multipleLanguages
                            showPaywall = true
                        }
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
                    .overlay(
                        Group {
                            if !premiumManager.isFeatureAvailable(.multipleLanguages) {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                    Text("Premium Feature")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                            }
                        }
                    )
                    
                    // Remove the Spacer and add a small fixed-height spacer instead
                    Spacer(minLength: 4)
                    
                    // Daily Dashboard button (moved to first position)
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
                    
                    // Category Selection Button
                    NavigationLink(destination: CategorySelectionView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "tag.fill")
                            Text("Choose Category")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.indigo)
                    .padding(.bottom, 10)
                    .overlay(
                        Group {
                            if !premiumManager.isFeatureAvailable(.advancedCategories) {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                    Text("Premium Feature")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                                .onTapGesture {
                                    selectedPremiumFeature = .advancedCategories
                                    showPaywall = true
                                }
                            }
                        }
                    )
                    
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
                    
                    // Quiz Mode button
                    NavigationLink(destination: QuizView().environmentObject(viewModel)) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                            Text("Quiz Mode")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .padding(.bottom, 10)
                    .overlay(
                        Group {
                            if !premiumManager.isFeatureAvailable(.quizEnhancements) {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                    Text("Premium Feature")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                                .onTapGesture {
                                    selectedPremiumFeature = .quizEnhancements
                                    showPaywall = true
                                }
                            }
                        }
                    )
                    
                    // Weekly Review button
                    NavigationLink(destination: WeeklyReviewView()) {
                        HStack {
                            Image(systemName: "calendar.badge.clock")
                            Text("Weekly Review")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .padding(.bottom, 10)
                    .overlay(
                        Group {
                            if !premiumManager.isFeatureAvailable(.weeklyReview) {
                                VStack {
                                    Image(systemName: "lock.fill")
                                        .font(.title)
                                        .foregroundColor(.secondary)
                                    Text("Premium Feature")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black.opacity(0.1))
                                .onTapGesture {
                                    selectedPremiumFeature = .weeklyReview
                                    showPaywall = true
                                }
                            }
                        }
                    )
                    
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
                    .tint(.gray)
                    .padding(.bottom, 10)
                }
                .padding()
            }
            .navigationDestination(isPresented: $showLanguageSelection) {
                LanguageSelectionView().environmentObject(viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                if let feature = selectedPremiumFeature {
                    PaywallView(feature: feature)
                }
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
