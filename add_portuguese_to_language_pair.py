#!/usr/bin/env python3

import re

# Read the current LanguagePair.swift file
with open('Language Byte Watch App/Models/LanguagePair.swift', 'r', encoding='utf-8') as f:
    content = f.read()

# Add Portuguese to language definitions
content = content.replace(
    'static let haitianCreole = Language(code: "ht", name: "Haitian Creole", speechCode: "ht-HT")',
    'static let haitianCreole = Language(code: "ht", name: "Haitian Creole", speechCode: "ht-HT")\n    static let portuguese = Language(code: "pt", name: "Portuguese", speechCode: "pt-BR")'
)

# Add Portuguese to allLanguages array
content = content.replace(
    '.english, .spanish, .french, .german, .italian, .japanese, .chinese, .korean, .haitianCreole',
    '.english, .spanish, .french, .german, .italian, .japanese, .chinese, .korean, .haitianCreole, .portuguese'
)

# Write the updated content back to the file
with open('Language Byte Watch App/Models/LanguagePair.swift', 'w', encoding='utf-8') as f:
    f.write(content)

print("Successfully added Portuguese to LanguagePair.swift") 