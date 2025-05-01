#!/usr/bin/env python3

import json
import os

def reformat_json_file():
    # Read the current JSON file
    with open('Language Byte Watch App/multilingual_words.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # Create a new formatted structure
    formatted_data = []
    
    for language_pair in data:
        # Create a new formatted language pair
        formatted_pair = {
            "source": language_pair["source"],
            "target": language_pair["target"],
            "name": language_pair["name"],
            "pairs": []
        }
        
        # Group pairs by category
        categories = {}
        for pair in language_pair["pairs"]:
            category = pair["category"]
            if category not in categories:
                categories[category] = []
            categories[category].append(pair)
        
        # Add pairs grouped by category
        for category, pairs in categories.items():
            # Add category comment
            formatted_pair["pairs"].append(f"// {category.capitalize()}")
            # Add pairs for this category
            formatted_pair["pairs"].extend(pairs)
        
        formatted_data.append(formatted_pair)
    
    # Write the reformatted JSON back to the file
    with open('Language Byte Watch App/multilingual_words.json', 'w', encoding='utf-8') as f:
        json.dump(formatted_data, f, indent=2, ensure_ascii=False)

if __name__ == "__main__":
    reformat_json_file()
    print("Successfully reformatted multilingual_words.json") 