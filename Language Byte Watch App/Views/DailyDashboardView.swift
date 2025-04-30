import SwiftUI

struct DailyDashboardView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    @AppStorage("quiz_totalAttempts") var totalAttempts: Int = 0
    @AppStorage("quiz_correctAnswers") var correctAnswers: Int = 0
    @AppStorage("quiz_bestStreak") var bestStreak: Int = 0
    @State private var showQuizStats = false
    @State private var showCategorySelection = false
    @State private var showResetConfirmation = false
    @State private var showResetSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Word of the Day Section
                    VStack(spacing: 10) {
                        Text("Today's Word")
                            .font(.headline)
                        
                        AdaptiveMarqueeText(
                            text: viewModel.wordOfTheDayTarget,
                            font: .largeTitle,
                            speed: 50,
                            delay: 1
                        )
                        .multilineTextAlignment(.center)
                        .frame(height: 40)
                        .padding(.top, 20)
                        
                        Text(viewModel.wordOfTheDaySource)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // Quiz Stats Section
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📈 Quiz Performance")
                            .font(.headline)
                            .padding(.top, 12)

                        if totalAttempts > 0 {
                            Text("✅ Correct: \(correctAnswers)")
                            Text("❌ Incorrect: \(totalAttempts - correctAnswers)")
                            Text("🎯 Accuracy: \(Int(Double(correctAnswers) / Double(totalAttempts) * 100))%")
                            Text("🔥 Best Streak: \(bestStreak)")
                        } else {
                            Text("No quiz attempts yet")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        showQuizStats = true
                    }) {
                        HStack {
                            Image(systemName: "chart.pie.fill")
                            Text("View Quiz Stats")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.purple)
                    .padding(.top, 10)
                    
                    Divider()
                    
                    // Daily Progress Section
                    VStack(spacing: 10) {
                        Text("Daily Progress")
                            .font(.headline)
                        
                        Text("\(viewModel.wordsStudiedToday)/\(viewModel.dailyGoal) words studied")
                            .font(.title3)
                            .padding()
                    }
                    
                    Divider()
                    
                    // Quick Access Buttons Section
                    VStack(spacing: 15) {
                        // Category section with debug coloring
                        VStack(spacing: 10) {
                            // Show currently selected category (moved here for better visibility)
                            if let category = viewModel.selectedCategory {
                                Text("Currently Studying: \(category.capitalized)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 5)
                            } else {
                                Text("Currently Studying: All Categories")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 5)
                            }
                            
                            // Category selection buttons
                            NavigationLink(destination: CategorySelectionView().environmentObject(viewModel)) {
                                HStack {
                                    Image(systemName: "tag.fill")
                                    Text("Choose Category")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue) // Changed to more visible blue
                            
                            Button(action: {
                                showResetConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward.circle.fill")
                                    Text("Reset Category")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange) // Changed to more visible orange
                            
                            if showResetSuccessMessage {
                                Text("✅ Category reset")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.bottom, 4)
                                    .transition(.opacity)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1)) // Debug background
                        .cornerRadius(10)
                        
                        // Other buttons (Start Studying, Favorites, Settings)
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
                        
                        NavigationLink(destination: FavoritesView().environmentObject(viewModel)) {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Favorites")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        
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
                    }
                    .confirmationDialog("Are you sure you want to reset the category filter?", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                        Button("Reset Category", role: .destructive) {
                            viewModel.selectCategory(nil)
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showResetSuccessMessage = true
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showResetSuccessMessage = false
                                }
                            }
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
                .padding()
            }
            .navigationTitle("Daily Dashboard")
            .onAppear {
                DispatchQueue.main.async {
                    self.viewModel.updateWordOfTheDayIfNeeded()
                }
            }
            .navigationDestination(isPresented: $showQuizStats) {
                QuizStatsView()
            }
        }
    }
}

#Preview {
    DailyDashboardView()
        .environmentObject(WordViewModel())
} 