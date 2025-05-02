import SwiftUI

// Local achievement struct for calculating badge progress
fileprivate struct DashboardAchievement: Identifiable {
    let id: String
}

struct DailyDashboardView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    @StateObject private var xpManager = XPManager()
    
    // Use State rather than AppStorage to ensure values are refreshed on view appear
    @State private var totalAttempts: Int = 0
    @State private var correctAnswers: Int = 0
    @State private var bestStreak: Int = 0
    @State private var unlockedBadges: Int = 0
    @State private var totalBadges: Int = 11 // Total number of available badges
    
    @State private var showQuizStats = false
    @State private var showCategorySelection = false
    @State private var showResetConfirmation = false
    @State private var showResetSuccessMessage = false
    @State private var showAchievements = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // XP and Level Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("🧠 Level \(xpManager.userLevel)")
                                .font(.headline)
                            Spacer()
                            Text(xpManager.getLevelTitle())
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        ProgressView(value: xpManager.getLevelProgress(), total: 1.0)
                            .tint(.blue)
                            .frame(height: 6)
                        
                        HStack {
                            Text("\(xpManager.xpTotal) XP total • \(xpManager.xpToNextLevel()) XP to next level")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue.opacity(0.1))
                    )
                    
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
                    
                    // Achievements Summary Section
                    VStack(spacing: 8) {
                        HStack {
                            Text("🏅 Achievements")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            Text("🔓 \(unlockedBadges) of \(totalBadges) Badges Unlocked")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        
                        // Progress bar for badges
                        ProgressView(value: Double(unlockedBadges), total: Double(totalBadges))
                            .tint(.yellow)
                            .frame(height: 4)
                            .padding(.bottom, 4)
                    }
                    .padding(.horizontal, 4)
                    
                    Button(action: {
                        // Refresh stats before showing achievements view
                        refreshQuizStats()
                        calculateUnlockedBadges()
                        showAchievements = true
                    }) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Achievements")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.orange)
                    
                    Divider()
                    
                    // Quiz Stats Section - Improved with better visibility
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("📈 Quiz Performance")
                                .font(.headline)
                            
                            Spacer()
                            
                            // Add a refresh button
                            Button(action: {
                                refreshQuizStats()
                                calculateUnlockedBadges()
                            }) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.caption)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.top, 12)

                        if totalAttempts > 0 {
                            Text("✅ Correct: \(correctAnswers)")
                                .foregroundColor(.green)
                            Text("❌ Incorrect: \(totalAttempts - correctAnswers)")
                                .foregroundColor(.red)
                            Text("🎯 Accuracy: \(calculateAccuracy())%")
                                .foregroundColor(.blue)
                            Text("🔥 Best Streak: \(bestStreak)")
                                .foregroundColor(.orange)
                        } else {
                            Text("No quiz attempts yet")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 8)
                    
                    Button(action: {
                        // Refresh stats before showing detailed view
                        refreshQuizStats()
                        calculateUnlockedBadges()
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
                        Text("Quick Actions")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Language Selection Button
                        Button(action: {
                            viewModel.showLanguagePicker = true
                        }) {
                            HStack {
                                Text(viewModel.selectedLanguagePair != nil ? 
                                    "\(viewModel.selectedLanguagePair!.sourceLanguage.name) → \(viewModel.selectedLanguagePair!.targetLanguage.name)" : 
                                    "Select Language")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        // Category Filter Button
                        Button(action: {
                            showCategorySelection = true
                        }) {
                            HStack {
                                Text("Category: \(viewModel.selectedCategory?.capitalized ?? "All")")
                                Image(systemName: "chevron.right")
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        // Reset Category Filter Button
                        if viewModel.selectedCategory != nil && viewModel.selectedCategory?.lowercased() != "all" {
                            VStack {
                                Button(action: {
                                    showResetConfirmation = true
                                }) {
                                    Text("Reset Category Filter")
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 16)
                                }
                                .buttonStyle(.plain)
                                
                                if showResetSuccessMessage {
                                    Text("✅ Category reset")
                                        .font(.caption)
                                        .foregroundColor(.green)
                                        .padding(.bottom, 4)
                                        .transition(.opacity)
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
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
                // Refresh all data when view appears
                DispatchQueue.main.async {
                    refreshXPValues()
                    refreshQuizStats()
                    calculateUnlockedBadges()
                    self.viewModel.updateWordOfTheDayIfNeeded()
                }
            }
            .navigationDestination(isPresented: $showQuizStats) {
                QuizStatsView()
            }
            .navigationDestination(isPresented: $showAchievements) {
                AchievementsView()
            }
            .navigationDestination(isPresented: $showCategorySelection) {
                CategorySelectionView().environmentObject(viewModel)
            }
            // Listen for XP update notifications
            .onReceive(NotificationCenter.default.publisher(for: XPManager.xpUpdatedNotification)) { _ in
                // Just trigger a view refresh - XPManager already updates its values
            }
            // Listen for level-up notifications to show feedback
            .onReceive(NotificationCenter.default.publisher(for: XPManager.levelUpNotification)) { notification in
                if let newLevel = notification.userInfo?["newLevel"] as? Int {
                    // You could trigger a level-up animation or alert here
                    print("Leveled up to \(newLevel)!")
                }
            }
        }
    }
    
    // Helper function to calculate accuracy with protection against division by zero
    private func calculateAccuracy() -> Int {
        guard totalAttempts > 0 else { return 0 }
        return Int(Double(correctAnswers) / Double(totalAttempts) * 100)
    }
    
    // Helper function to refresh quiz stats from UserDefaults
    private func refreshQuizStats() {
        totalAttempts = UserDefaults.standard.integer(forKey: "quiz_totalAttempts")
        correctAnswers = UserDefaults.standard.integer(forKey: "quiz_correctAnswers")
        bestStreak = UserDefaults.standard.integer(forKey: "quiz_bestStreak")
        print("📊 Refreshed quiz stats: \(correctAnswers)/\(totalAttempts) attempts, \(bestStreak) best streak")
    }
    
    // Calculate unlocked badges count using logic similar to QuizStatsView
    private func calculateUnlockedBadges() {
        let accuracy = calculateAccuracy()
        
        var unlockedCount = 0
        
        // Check each achievement condition
        if correctAnswers >= 10 { unlockedCount += 1 } // starter
        if correctAnswers >= 25 { unlockedCount += 1 } // beginner
        if bestStreak >= 5 { unlockedCount += 1 } // hotstreak
        if bestStreak >= 10 { unlockedCount += 1 } // inferno
        if accuracy >= 80 && totalAttempts >= 20 { unlockedCount += 1 } // accurate
        if accuracy >= 90 && totalAttempts >= 50 { unlockedCount += 1 } // brainiac
        if correctAnswers >= 15 && correctAnswers == totalAttempts { unlockedCount += 1 } // perfect
        if totalAttempts >= 100 { unlockedCount += 1 } // dedicated
        if totalAttempts >= 250 && Double(correctAnswers) / Double(totalAttempts) >= 0.85 { unlockedCount += 1 } // master
        if UserDefaults.standard.bool(forKey: "quiz_comeback") { unlockedCount += 1 } // comeback
        if UserDefaults.standard.bool(forKey: "quiz_speedster") { unlockedCount += 1 } // speedster
        
        unlockedBadges = unlockedCount
    }
    
    // Helper function to refresh XP values
    private func refreshXPValues() {
        // XPManager automatically loads values from UserDefaults
        // This is just to trigger a UI refresh if needed
        _ = xpManager.xpTotal
        _ = xpManager.userLevel
    }
}

#Preview {
    DailyDashboardView()
        .environmentObject(WordViewModel())
} 