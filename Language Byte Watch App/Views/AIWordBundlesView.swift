import SwiftUI
import StoreKit

// Import necessary view models and managers
import class Language_Byte_Watch_App.AIWordBundlesViewModel
import class Language_Byte_Watch_App.PremiumAccessManager

// Import models
import struct Language_Byte_Watch_App.WordPair
import struct Language_Byte_Watch_App.WordBundle
import struct Language_Byte_Watch_App.PerformanceInsight

// Import views
import struct Language_Byte_Watch_App.PaywallView

// Import modifiers
import enum Language_Byte_Watch_App.PremiumFeature

struct AIWordBundlesView: View {
    @StateObject private var viewModel = AIWordBundlesViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.aiWordBundles) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .aiWordBundles)
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Smart Practice")
                    .font(.title2)
                    .bold()
                
                Text("AI-powered word recommendations based on your learning patterns")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Performance Insights
                PerformanceInsightsView(insights: viewModel.performanceInsights)
                
                // Word Bundles
                ForEach(viewModel.wordBundles) { bundle in
                    WordBundleCard(bundle: bundle) {
                        viewModel.startPractice(with: bundle)
                    }
                }
                
                // Generate New Bundle Button
                Button("Generate New Bundle") {
                    viewModel.generateNewBundle()
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isGenerating)
            }
            .padding()
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: PremiumFeature.aiWordBundles.icon)
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Smart Practice")
                .font(.title2)
                .bold()
            
            Text(PremiumFeature.aiWordBundles.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Upgrade to Premium") {
                showPaywall = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct PerformanceInsightsView: View {
    let insights: [PerformanceInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Learning Insights")
                .font(.headline)
            
            ForEach(insights) { insight in
                HStack {
                    Image(systemName: insight.icon)
                        .foregroundColor(.blue)
                    Text(insight.description)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

struct WordBundleCard: View {
    let bundle: WordBundle
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(bundle.title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(bundle.words.count) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(bundle.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(bundle.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            Button("Start Practice") {
                action()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    AIWordBundlesView()
} 