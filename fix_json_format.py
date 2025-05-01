#!/usr/bin/env python3

import json

# Read the current JSON file
with open('Language Byte Watch App/multilingual_words.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Format it with proper indentation and sorted keys
with open('Language Byte Watch App/multilingual_words.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False, sort_keys=False)

print("Successfully reformatted the JSON file") 