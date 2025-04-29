import Foundation
import SwiftUI

struct FavoriteWord: Codable, Identifiable, Equatable {
    let id = UUID()
    let sourceWord: String
    let targetWord: String
    let sourceLanguageCode: String
    let targetLanguageCode: String
    
    static func == (lhs: FavoriteWord, rhs: FavoriteWord) -> Bool {
        return lhs.sourceWord == rhs.sourceWord && lhs.targetWord == rhs.targetWord
    }
}

class FavoritesManager: ObservableObject {
    @Published private(set) var favoriteWords: [FavoriteWord] = []
    
    private let favoritesKey = "favoriteWords"
    
    init() {
        loadFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey) {
            if let decoded = try? JSONDecoder().decode([FavoriteWord].self, from: data) {
                favoriteWords = decoded
            }
        }
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteWords) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }
    
    func addFavorite(sourceWord: String, targetWord: String, sourceLanguage: String, targetLanguage: String) {
        let newFavorite = FavoriteWord(
            sourceWord: sourceWord,
            targetWord: targetWord,
            sourceLanguageCode: sourceLanguage,
            targetLanguageCode: targetLanguage
        )
        
        if !isFavorite(sourceWord: sourceWord, targetWord: targetWord) {
            favoriteWords.append(newFavorite)
            saveFavorites()
        }
    }
    
    func removeFavorite(sourceWord: String, targetWord: String) {
        favoriteWords.removeAll { favorite in
            favorite.sourceWord == sourceWord && favorite.targetWord == targetWord
        }
        saveFavorites()
    }
    
    func isFavorite(sourceWord: String, targetWord: String) -> Bool {
        return favoriteWords.contains { favorite in
            favorite.sourceWord == sourceWord && favorite.targetWord == targetWord
        }
    }
} 