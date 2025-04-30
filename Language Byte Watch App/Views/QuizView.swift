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
    
    var body: some View {
        // Simpler layout structure with fewer nested containers
        ZStack {
            // Main content - use VStack with spacer for proper element distribution
            VStack(spacing: 0) {
                // Top bar with title and feedback
                HStack {
                    Spacer()
                    
                    Text("Quiz Mode Score")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                    
                    Text("\(correctAnswers)/\(totalAttempts)")
                        .font(.system(size: 16))
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                // Word display - centered with proper spacing
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
                                totalAttempts += 1
                                selectedChoice = choice
                                isCorrect = (choice == question.correctAnswer)
                                if isCorrect {
                                    correctAnswers += 1
                                    currentStreak += 1
                                    if currentStreak > bestStreak {
                                        bestStreak = currentStreak
                                    }
                                } else {
                                    currentStreak = 0
                                }
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
            generateNewQuestion()
        }
        .confirmationDialog(
            "Leave Quiz?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("Leave", role: .destructive) {
                resetQuiz()
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
    }
    
    // Reset the quiz state for a fresh start next time
    private func resetQuiz() {
        // Reset current session state
        showFeedback = false
        isCorrect = false
        selectedChoice = ""
        currentQuestion = nil
        currentStreak = 0
        
        // Reset score counters
        correctAnswers = 0
        totalAttempts = 0
        
        // Note: We keep the bestStreak in AppStorage as a high score record
        // but reset all other variables
    }
    
    // STEP 4: Define a local function to generate a quiz question
    private func generateNewQuestion() {
        let allWords = viewModel.allWords.shuffled()
        
        guard allWords.count >= 3 else { return }
        
        let correctPair = allWords[0]
        let wrongChoices = allWords[1...].prefix(2).map { $0.foreignWord }
        
        var choices = wrongChoices + [correctPair.foreignWord]
        choices.shuffle()
        
        currentQuestion = QuizQuestion(
            sourceWord: correctPair.translation,
            correctAnswer: correctPair.foreignWord,
            choices: choices
        )
        showFeedback = false
        selectedChoice = ""
    }
}

// STEP 9: Define a supporting model struct
struct QuizQuestion {
    let sourceWord: String
    let correctAnswer: String
    let choices: [String]
}

#Preview {
    NavigationStack {
        QuizView()
            .environmentObject(WordViewModel())
    }
} 
