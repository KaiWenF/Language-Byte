//
//  WordHistoryView.swift
//  Language Byte
//
//  Created by Kevin Franklin on 2/14/25.
//
import SwiftUI

struct WordHistoryView: View {
    @EnvironmentObject var viewModel: WordViewModel  // Access ViewModel

    var body: some View {
        List {
            Section(header: Text("Word History")) {
                if viewModel.wordHistory.isEmpty {
                    Text("No words seen yet").foregroundColor(.gray)
                } else {
                    ForEach(viewModel.wordHistory, id: \.foreignWord) { wordPair in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(wordPair.foreignWord)
                                    .font(.headline)
                                Text(wordPair.translation)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                viewModel.speakWord(wordPair.foreignWord)
                            }) {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                    }
                    .onDelete(perform: deleteWord)  // ✅ Enable swipe-to-delete
                }
            }
        }
        .toolbar {
            Button("Clear History") {
                viewModel.clearWordHistory()
            }
            .foregroundColor(.red)
        }
        .navigationTitle("Word History")
        .onAppear {
            print("📌 WordHistoryView loaded. Current word history:", viewModel.wordHistory.map { "\($0.foreignWord) - \($0.translation)" })
            viewModel.objectWillChange.send()  // ✅ Ensure UI updates
        }
    }

    
    /// ✅ Removes a word from history (Swipe-to-Delete)
    private func deleteWord(at offsets: IndexSet) {
        viewModel.wordHistory.remove(atOffsets: offsets)
        viewModel.saveWordHistory()
    }
}
