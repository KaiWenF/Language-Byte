#!/usr/bin/env python3

with open('Language Byte Watch App/Models/LanguagePair.swift', 'r') as f:
    content = f.read()

# Add Haitian Creole
new_content = content.replace(
    'static let korean = Language(code: "ko", name: "Korean", speechCode: "ko-KR")',
    'static let korean = Language(code: "ko", name: "Korean", speechCode: "ko-KR")\n    static let haitianCreole = Language(code: "ht", name: "Haitian Creole", speechCode: "ht-HT")'
)

# Update allLanguages array
new_content = new_content.replace(
    '.english, .spanish, .french, .german, .italian, .japanese, .chinese, .korean',
    '.english, .spanish, .french, .german, .italian, .japanese, .chinese, .korean, .haitianCreole'
)

with open('Language Byte Watch App/Models/LanguagePair.swift', 'w') as f:
    f.write(new_content)

print('Successfully added Haitian Creole to LanguagePair.swift') 