//
//  QuizView.swift
//  Language Byte Watch App
//
//  Created by Kai Wen on 3/21/2025.
//

import SwiftUI

struct QuizView: View {
    // STEP 1: Use EnvironmentObject for WordViewModel (reuse the words already loaded)
    @EnvironmentObject var viewModel: WordViewModel
    
    // XP Manager for streak bonuses
    @StateObject private var xpManager = XPManager()
    
    // STEP 2: Create state variables to hold the current quiz question and feedback state
    @State private var currentQuestion: QuizQuestion? = nil
    @State private var showFeedback: Bool = false
    @State private var isCorrect: Bool = false
    @State private var selectedChoice: String = ""
    
    // Use AppStorage to persist stats across app launches
    @AppStorage("quiz_totalAttempts") private var totalAttempts: Int = 0
    @AppStorage("quiz_correctAnswers") private var correctAnswers: Int = 0
    @AppStorage("quiz_bestStreak") private var bestStreak: Int = 0
    @State private var currentStreak: Int = 0
    @State private var showExitConfirmation: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    
    // Streak milestone tracking with AppStorage
    @AppStorage("streak_milestone_5_awarded") private var streakMilestone5Awarded = false
    @AppStorage("streak_milestone_10_awarded") private var streakMilestone10Awarded = false  
    @AppStorage("streak_milestone_15_awarded") private var streakMilestone15Awarded = false
    @AppStorage("streak_milestone_date") private var streakMilestoneDate = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                // Score display
                HStack {
                    Text("Quiz Mode")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(correctAnswers)/\(totalAttempts)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Quiz content
                if let question = currentQuestion {
                    Spacer()
                    
                    // Simple text with larger font instead of AdaptiveMarqueeText
                    Text(question.sourceWord)
                        .font(.system(size: 42, weight: .regular))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    // Buttons stack
                    VStack(spacing: 8) {
                        ForEach(question.choices, id: \.self) { choice in
                            Button(action: {
                                // Update quiz statistics
                                totalAttempts += 1
                                selectedChoice = choice
                                isCorrect = (choice == question.correctAnswer)
                                
                                if isCorrect {
                                    correctAnswers += 1
                                    currentStreak += 1
                                    
                                    // Award 10 XP for each correct answer
                                    xpManager.addXP(10)
                                    
                                    // Check for streak milestones
                                    checkStreakMilestones()
                                    
                                    if currentStreak > bestStreak {
                                        bestStreak = currentStreak
                                    }
                                } else {
                                    currentStreak = 0
                                }
                                
                                // Update UserDefaults directly to ensure values are saved
                                UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
                                UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
                                UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
                                UserDefaults.standard.synchronize()
                                
                                showFeedback = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    generateNewQuestion()
                                }
                            }) {
                                Text(choice)
                                    .font(.body)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .frame(height: 44)
                            .tint(showFeedback && choice == selectedChoice ? 
                                  (isCorrect ? .green : .red) : nil)
                        }
                    }
                    .padding(.bottom, 10)
                } else {
                    Spacer()
                    Text("Loading quiz...")
                    Spacer()
                }
            }
            .padding(.horizontal, 8)
        }
        .onAppear {
            // Ensure existing UserDefaults values are loaded
            loadSavedStats()
            generateNewQuestion()
            
            // Reset streak milestones if it's a new day
            let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
            if streakMilestoneDate != today {
                streakMilestone5Awarded = false
                streakMilestone10Awarded = false
                streakMilestone15Awarded = false
                streakMilestoneDate = today
            }
        }
        .confirmationDialog(
            "Leave Quiz?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave", role: .destructive) {
                saveQuizStats() // Ensure stats are saved before leaving
                presentationMode.wrappedValue.dismiss()
            }
            Button("Stay", role: .cancel) { }
        } message: {
            Text("Your progress will be saved, but you'll start with a new question next time.")
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(action: {
                    showExitConfirmation = true
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                }
            }
        }
        .overlay(
            // Streak milestone toast
            ZStack {
                if showStreakToast {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            
                            Text(streakMilestoneMessage)
                                .font(.callout)
                                .bold()
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.2))
                                .shadow(radius: 2)
                        )
                        .padding(.bottom, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: showStreakToast)
                    }
                }
            }
        )
    }
    
    // Load saved statistics from UserDefaults
    private func loadSavedStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        print("📊 Loaded quiz stats: \(correctAnswers)/\(totalAttempts) attempts, \(bestStreak) best streak")
    }
    
    // Save quiz statistics to UserDefaults
    private func saveQuizStats() {
        UserDefaults.standard.set(totalAttempts, forKey: "quiz_totalAttempts")
        UserDefaults.standard.set(correctAnswers, forKey: "quiz_correctAnswers")
        UserDefaults.standard.set(bestStreak, forKey: "quiz_bestStreak")
        UserDefaults.standard.synchronize()
        print("📊 Saved quiz stats: \(correctAnswers)/\(totalAttempts) attempts, \(bestStreak) best streak")
    }
    
    // Reset the quiz state for a fresh start next time
    private func resetQuiz() {
        // Reset current session state
        showFeedback = false
        isCorrect = false
        selectedChoice = ""
        currentQuestion = nil
        currentStreak = 0
        
        // Keep the statistics in place
        // We don't reset correctAnswers, totalAttempts or bestStreak anymore
        
        // Save the current state
        saveQuizStats()
    }
    
    // STEP 4: Define a local function to generate a quiz question
    private func generateNewQuestion() {
        let allWords = viewModel.allWords.shuffled()
        
        guard allWords.count >= 3 else { return }
        
        let correctPair = allWords[0]
        let wrongChoices = allWords[1...].prefix(2).map { $0.sourceWord }
        
        var choices = wrongChoices + [correctPair.sourceWord]
        choices.shuffle()
        
        currentQuestion = QuizQuestion(
            sourceWord: correctPair.targetWord,
            correctAnswer: correctPair.sourceWord,
            choices: choices
        )
        showFeedback = false
        selectedChoice = ""
    }
    
    // Check and award XP bonuses for streak milestones
    private func checkStreakMilestones() {
        // First, check if we need to reset milestone tracking (new day)
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if streakMilestoneDate != today {
            // It's a new day, reset all milestone flags
            streakMilestone5Awarded = false
            streakMilestone10Awarded = false
            streakMilestone15Awarded = false
            streakMilestoneDate = today
        }
        
        // Check if any milestone has been reached and not yet awarded today
        if currentStreak == 5 && !streakMilestone5Awarded {
            xpManager.addXP(20)
            streakMilestone5Awarded = true
            showStreakMilestoneMessage("5-Answer Streak! +20 XP")
        } else if currentStreak == 10 && !streakMilestone10Awarded {
            xpManager.addXP(35)
            streakMilestone10Awarded = true
            showStreakMilestoneMessage("10-Answer Streak! +35 XP")
        } else if currentStreak == 15 && !streakMilestone15Awarded {
            xpManager.addXP(50)
            streakMilestone15Awarded = true
            showStreakMilestoneMessage("15-Answer Streak! +50 XP")
        }
    }
    
    // Show a toast message for streak milestones
    @State private var streakMilestoneMessage = ""
    @State private var showStreakToast = false
    
    private func showStreakMilestoneMessage(_ message: String) {
        streakMilestoneMessage = message
        showStreakToast = true
        
        // Hide the toast after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showStreakToast = false
            }
        }
    }
}

// STEP 9: Define a supporting model struct
// QuizQuestion is now defined in Models/QuizModels.swift
// struct QuizQuestion {
//     let sourceWord: String
//     let correctAnswer: String
//     let choices: [String]
// }

#Preview {
    NavigationStack {
        QuizView()
            .environmentObject(WordViewModel())
    }
} 
