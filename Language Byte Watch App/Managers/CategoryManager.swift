//
//  CategoryManager.swift
//  Language Byte Watch App
//
//  Created on [Current Date]
//

import Foundation

/// A utility for managing language categories from JSON files
struct CategoryManager {
    
    /// Get all available categories for a specific source-target language pair
    /// - Parameters:
    ///   - source: Source language code (e.g., "en", "es", "fr")
    ///   - target: Target language code (e.g., "es", "fr", "pt")
    /// - Returns: Array of available category names
    static func getAvailableCategories(source: String, target: String) -> [String] {
        // Define the prefix pattern for filtering files
        let filePrefix = "\(source)_\(target)_"
        
        // Get all JSON files in the LanguageData directory
        guard let fileURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "LanguageData") else {
            print("⚠️ No JSON files found in LanguageData directory")
            return []
        }
        
        // Extract categories from filenames that match the pattern
        let categories = fileURLs.compactMap { url -> String? in
            let filename = url.lastPathComponent
            
            // Filter files that match our source-target pattern
            guard filename.hasPrefix(filePrefix) else {
                return nil
            }
            
            // Extract the category part from the filename
            // Format: source_target_category.json
            let withoutPrefix = filename.dropFirst(filePrefix.count)
            let withoutExtension = withoutPrefix.replacingOccurrences(of: ".json", with: "")
            
            // Convert underscores back to spaces and capitalize for display
            return withoutExtension.replacingOccurrences(of: "_", with: " ").capitalized
        }
        
        // Remove duplicates, sort and return
        return Array(Set(categories)).sorted()
    }
    
    /// Get all available categories from a specific source language subdirectory
    /// - Parameter source: Source language code (e.g., "en", "es", "fr")
    /// - Returns: Array of available category names
    static func getAvailableCategories(forSourceLanguage source: String) -> [String] {
        // First, check if source language directory exists
        let sourceDirPath = "LanguageData/\(source)"
        
        guard let fileURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: sourceDirPath) else {
            print("⚠️ No JSON files found in \(sourceDirPath) directory")
            return []
        }
        
        // Extract categories from all files in the source language directory
        let categories = fileURLs.compactMap { url -> String? in
            let filename = url.lastPathComponent
            
            // Format: source_target_category.json
            let components = filename.split(separator: "_")
            guard components.count >= 3 else { return nil }
            
            // The category is everything after the second underscore, without extension
            let categoryWithExt = components[2...].joined(separator: "_")
            let category = categoryWithExt.replacingOccurrences(of: ".json", with: "")
            
            // Convert underscores back to spaces and capitalize for display
            return category.replacingOccurrences(of: "_", with: " ").capitalized
        }
        
        // Remove duplicates, sort and return
        return Array(Set(categories)).sorted()
    }
    
    /// Get all available language pairs as source-target tuples
    /// - Returns: Array of tuples containing (source, target) language code pairs
    static func getAvailableLanguagePairs() -> [(source: String, target: String)] {
        // Get all JSON files in the LanguageData directory
        guard let fileURLs = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "LanguageData") else {
            print("⚠️ No JSON files found in LanguageData directory")
            return []
        }
        
        // Extract language pairs from filenames
        let pairs = fileURLs.compactMap { url -> (source: String, target: String)? in
            let filename = url.lastPathComponent
            
            // Format: source_target_category.json
            let components = filename.split(separator: "_")
            guard components.count >= 2 else { return nil }
            
            let source = String(components[0])
            let target = String(components[1])
            
            return (source: source, target: target)
        }
        
        // Remove duplicates by converting to a set of tuples
        let uniquePairs = Set(pairs.map { "\($0.source)_\($0.target)" }).map { pair -> (source: String, target: String) in
            let components = pair.split(separator: "_")
            return (source: String(components[0]), target: String(components[1]))
        }
        
        return uniquePairs.sorted { $0.source < $1.source || ($0.source == $1.source && $0.target < $1.target) }
    }
} 