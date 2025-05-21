import SwiftUI
import AVFoundation

struct VoiceCustomizationView: View {
    @StateObject private var viewModel = VoiceCustomizationViewModel()
    @StateObject private var premiumManager = PremiumAccessManager.shared
    @State private var showPaywall = false
    
    var body: some View {
        Group {
            if premiumManager.isFeatureAvailable(.voiceCustomization) {
                content
            } else {
                lockedContent
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(feature: .voiceCustomization)
        }
    }
    
    private var content: some View {
        List {
            Section(header: Text("Voice Settings")) {
                Picker("Voice", selection: $viewModel.selectedVoice) {
                    ForEach(viewModel.availableVoices, id: \.identifier) { voice in
                        Text(voice.name)
                            .tag(voice)
                    }
                }
                
                Picker("Speaking Rate", selection: $viewModel.speakingRate) {
                    ForEach(SpeakingRate.allCases, id: \.self) { rate in
                        Text(rate.description)
                            .tag(rate)
                    }
                }
                
                Toggle("Auto-play on View", isOn: $viewModel.autoPlay)
            }
            
            Section(header: Text("Preview")) {
                Button("Play Sample") {
                    viewModel.playSample()
                }
                .disabled(viewModel.isPlaying)
            }
        }
    }
    
    private var lockedContent: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Voice Customization")
                .font(.title2)
                .bold()
            
            Text("Unlock premium to customize your learning experience with multiple voices and speaking rates")
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

class VoiceCustomizationViewModel: ObservableObject {
    @Published var selectedVoice: VoiceOption
    @Published var speakingRate: SpeakingRate = .normal
    @Published var autoPlay: Bool = true
    @Published var isPlaying: Bool = false
    
    let availableVoices: [VoiceOption]
    private var synthesizer: AVSpeechSynthesizer?
    
    init() {
        // Initialize with default voice
        let defaultVoice = VoiceOption(
            identifier: "com.apple.ttsbundle.Samantha-compact",
            name: "Samantha",
            language: "en-US"
        )
        
        // Get available voices
        availableVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.starts(with: "en") }
            .map { VoiceOption(
                identifier: $0.identifier,
                name: $0.name,
                language: $0.language
            )}
        
        selectedVoice = availableVoices.first ?? defaultVoice
        synthesizer = AVSpeechSynthesizer()
    }
    
    func playSample() {
        guard let synthesizer = synthesizer else { return }
        
        isPlaying = true
        
        let utterance = AVSpeechUtterance(string: "Hello, welcome to Language Byte!")
        utterance.voice = AVSpeechSynthesisVoice(identifier: selectedVoice.identifier)
        utterance.rate = speakingRate.rawValue
        
        synthesizer.speak(utterance)
        
        // Reset playing state after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isPlaying = false
        }
    }
}

struct VoiceOption: Hashable {
    let identifier: String
    let name: String
    let language: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    
    static func == (lhs: VoiceOption, rhs: VoiceOption) -> Bool {
        lhs.identifier == rhs.identifier
    }
}

enum SpeakingRate: Float, CaseIterable {
    case slow = 0.5
    case normal = 0.7
    case fast = 0.9
    
    var description: String {
        switch self {
        case .slow: return "Slow"
        case .normal: return "Normal"
        case .fast: return "Fast"
        }
    }
}

#Preview {
    VoiceCustomizationView()
} 