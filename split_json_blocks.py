#!/usr/bin/env python3
import json
import os
import re

def safe_filename(text):
    """Convert a string to a safe filename by removing spaces and lowercasing"""
    return text.lower().replace(' ', '_')

def main():
    print("Starting language block processing...")
    
    # Path to the input file with Chinese blocks
    input_file = "portuguese_blocks.txt"
    
    # Base directory for output files
    output_base_dir = "Resources/LanguageData"
    
    # Ensure the base directory exists
    if not os.path.exists(output_base_dir):
        os.makedirs(output_base_dir)
    
    # Read the file content
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"Error: File {input_file} does not exist")
        return
    
    # The file starts with a comma, so we need to wrap it properly for JSON parsing
    json_content = '{"languages": [' + content.lstrip(',') + ']}'
    
    # Parse the JSON
    try:
        data = json.loads(json_content)
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        return
    
    # Counter for processed blocks
    blocks_processed = 0
    
    # Process each language block
    if 'languages' in data:
        for language_block in data['languages']:
            # Extract necessary information
            source_lang = language_block.get('source')
            target_lang = language_block.get('target')
            
            # Determine category by looking at the first pair's category or using a default
            category = "common"
            if 'pairs' in language_block and len(language_block['pairs']) > 0:
                # Get unique categories from all pairs
                categories = set()
                for pair in language_block['pairs']:
                    if 'category' in pair:
                        categories.add(pair['category'])
                
                # If there's only one category, use it
                if len(categories) == 1:
                    category = list(categories)[0]
            
            # Skip if missing required information
            if not source_lang or not target_lang:
                print(f"Skipping block: Missing source or target language")
                continue
            
            # Create source language directory if it doesn't exist
            source_dir = os.path.join(output_base_dir, source_lang)
            if not os.path.exists(source_dir):
                os.makedirs(source_dir)
            
            # Construct filename: {sourceLang}_{targetLang}_{category}.json
            filename = f"{source_lang}_{target_lang}_{safe_filename(category)}.json"
            output_path = os.path.join(source_dir, filename)
            
            # Write the language block to its own file
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(language_block, f, ensure_ascii=False, indent=2)
            
            blocks_processed += 1
            print(f"Created: {output_path}")
    
    print(f"Processing complete. {blocks_processed} language blocks processed.")

if __name__ == "__main__":
    main()