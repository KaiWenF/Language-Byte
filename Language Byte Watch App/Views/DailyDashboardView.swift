import SwiftUI

struct DailyDashboardView: View {
    @EnvironmentObject private var viewModel: WordViewModel
    
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
                }
                .padding()
            }
            .navigationTitle("Daily Dashboard")
            .onAppear {
                DispatchQueue.main.async {
                    self.viewModel.updateWordOfTheDayIfNeeded()
                }
            }
        }
    }
}

#Preview {
    DailyDashboardView()
        .environmentObject(WordViewModel())
} 