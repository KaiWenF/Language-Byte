#!/usr/bin/env python3

import json
import copy

# Read the current JSON file
with open('Language Byte Watch App/multilingual_words.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Find Spanish language data to use as a template
spanish_data = None
for lang in data["languages"]:
    if lang["source"] == "en" and lang["target"] == "es":
        spanish_data = lang
        break

if not spanish_data:
    print("Error: Spanish language data not found!")
    exit(1)

# Create Portuguese language entry based on Spanish
portuguese_data = copy.deepcopy(spanish_data)
portuguese_data["target"] = "pt"
portuguese_data["name"]["target"] = "Portuguese"

# Update with Portuguese translations
word_map = {
    # Verbs
    "comer": "comer",
    "beber": "beber",
    "cocinar": "cozinhar",
    "cortar": "cortar",
    "pelar": "descascar",
    "freír": "fritar",
    "hornear": "assar",
    "mezclar": "misturar",
    "probar": "provar",
    "sazonar": "temperar",
    
    # Food
    "pan": "pão",
    "queso": "queijo",
    "leche": "leite",
    "huevo": "ovo",
    "carne": "carne",
    "pescado": "peixe",
    "pollo": "frango",
    "arroz": "arroz",
    "frijoles": "feijão",
    "papas": "batatas",
    
    # Family
    "madre": "mãe",
    "padre": "pai",
    "hijo": "filho",
    "hija": "filha",
    "hermano": "irmão",
    "hermana": "irmã",
    "abuelo": "avô",
    "abuela": "avó",
    "tío": "tio",
    "tía": "tia",
    
    # Colors
    "rojo": "vermelho",
    "azul": "azul",
    "verde": "verde",
    "amarillo": "amarelo",
    "naranja": "laranja",
    "morado": "roxo",
    "rosa": "rosa",
    "negro": "preto",
    "blanco": "branco",
    "gris": "cinza",
    
    # Numbers
    "uno": "um",
    "dos": "dois",
    "tres": "três",
    "cuatro": "quatro",
    "cinco": "cinco",
    "seis": "seis",
    "siete": "sete",
    "ocho": "oito",
    "nueve": "nove",
    "diez": "dez",
    
    # Phrases
    "Hola": "Olá",
    "Buenos días": "Bom dia",
    "Buenas tardes": "Boa tarde",
    "Buenas noches": "Boa noite",
    "Adiós": "Adeus",
    "Por favor": "Por favor",
    "Gracias": "Obrigado",
    "De nada": "De nada",
    "Lo siento": "Sinto muito",
    "Perdón": "Desculpe"
}

# Update all words to Portuguese
for pair in portuguese_data["pairs"]:
    spanish_word = pair["targetWord"]
    if spanish_word in word_map:
        pair["targetWord"] = word_map[spanish_word]

# Add Portuguese to languages array
data["languages"].append(portuguese_data)

# Save the updated JSON back to the file
with open('Language Byte Watch App/multilingual_words.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False, sort_keys=False)

print("Successfully added Portuguese to language options!") 