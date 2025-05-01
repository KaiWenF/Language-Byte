import json

# Load existing JSON file
with open('Language Byte Watch App/multilingual_words.json', 'r') as f:
    data = json.load(f)

# Create Haitian Creole language entry
haitian_creole = {
    "source": "en",
    "target": "ht",
    "name": {
        "source": "English",
        "target": "Haitian Creole"
    },
    "pairs": [
        {"sourceWord": "Hello", "targetWord": "Bonjou", "category": "phrases"},
        {"sourceWord": "Good morning", "targetWord": "Bonjou", "category": "phrases"},
        {"sourceWord": "Good afternoon", "targetWord": "Bonswa", "category": "phrases"},
        {"sourceWord": "Good evening", "targetWord": "Bonswa", "category": "phrases"},
        {"sourceWord": "Goodbye", "targetWord": "Orevwa", "category": "phrases"},
        {"sourceWord": "Please", "targetWord": "Souple", "category": "phrases"},
        {"sourceWord": "Thank you", "targetWord": "Mèsi", "category": "phrases"},
        {"sourceWord": "You're welcome", "targetWord": "Pa gen pwoblèm", "category": "phrases"},
        {"sourceWord": "I'm sorry", "targetWord": "Mwen regret", "category": "phrases"},
        {"sourceWord": "Excuse me", "targetWord": "Eskize mwen", "category": "phrases"},
        
        {"sourceWord": "bread", "targetWord": "pen", "category": "food"},
        {"sourceWord": "rice", "targetWord": "diri", "category": "food"},
        {"sourceWord": "beans", "targetWord": "pwa", "category": "food"},
        {"sourceWord": "water", "targetWord": "dlo", "category": "food"},
        {"sourceWord": "meat", "targetWord": "vyann", "category": "food"},
        {"sourceWord": "fish", "targetWord": "pwason", "category": "food"},
        {"sourceWord": "chicken", "targetWord": "poul", "category": "food"},
        {"sourceWord": "banana", "targetWord": "bannann", "category": "food"},
        {"sourceWord": "plantain", "targetWord": "bannann peze", "category": "food"},
        {"sourceWord": "avocado", "targetWord": "zaboka", "category": "food"},
        
        {"sourceWord": "mother", "targetWord": "manman", "category": "family"},
        {"sourceWord": "father", "targetWord": "papa", "category": "family"},
        {"sourceWord": "son", "targetWord": "pitit gason", "category": "family"},
        {"sourceWord": "daughter", "targetWord": "pitit fi", "category": "family"},
        {"sourceWord": "brother", "targetWord": "frè", "category": "family"},
        {"sourceWord": "sister", "targetWord": "sè", "category": "family"},
        {"sourceWord": "grandmother", "targetWord": "grann", "category": "family"},
        {"sourceWord": "grandfather", "targetWord": "granpapa", "category": "family"},
        {"sourceWord": "aunt", "targetWord": "matant", "category": "family"},
        {"sourceWord": "uncle", "targetWord": "tonton", "category": "family"},
        
        {"sourceWord": "one", "targetWord": "en", "category": "numbers"},
        {"sourceWord": "two", "targetWord": "de", "category": "numbers"},
        {"sourceWord": "three", "targetWord": "twa", "category": "numbers"},
        {"sourceWord": "four", "targetWord": "kat", "category": "numbers"},
        {"sourceWord": "five", "targetWord": "senk", "category": "numbers"},
        {"sourceWord": "six", "targetWord": "sis", "category": "numbers"},
        {"sourceWord": "seven", "targetWord": "sèt", "category": "numbers"},
        {"sourceWord": "eight", "targetWord": "wit", "category": "numbers"},
        {"sourceWord": "nine", "targetWord": "nèf", "category": "numbers"},
        {"sourceWord": "ten", "targetWord": "dis", "category": "numbers"}
    ]
}

# Add Haitian Creole to the languages array
data['languages'].append(haitian_creole)

# Save the updated JSON file
with open('Language Byte Watch App/multilingual_words.json', 'w') as f:
    json.dump(data, f, indent=2)

print("Haitian Creole added successfully!") 