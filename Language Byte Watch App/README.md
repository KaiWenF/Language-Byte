# Language Byte Watch App

A comprehensive language learning application for Apple Watch that helps users learn new languages through interactive features and daily practice.

## Features

### Core Learning Features
- **Multi-language Support**: Learn multiple languages including Spanish, French, German, and Japanese
- **Word Pairs**: Study words and phrases with translations
- **Categories**: Organized learning by categories (verbs, food, family, colors, numbers, phrases)
- **Text-to-Speech**: Hear correct pronunciation in target language
- **Favorites**: Save and review your favorite words

### Interactive Quiz System
- **Score Tracking**: Track your progress with persistent scoring
- **Streak System**: Build and maintain learning streaks
- **Achievements**: Unlock various achievements:
  - Beginner achievements (Quiz Novice, Language Apprentice)
  - Streak-based achievements (On Fire, Unstoppable)
  - Accuracy-based achievements (Sharp Mind, Brainiac, Perfect Recall)
  - Mastery achievements (Dedicated Scholar, Language Master)
  - Special achievements (Comeback Kid, Quick Thinker)
- **Visual Feedback**: Immediate feedback for correct/incorrect answers
- **Progress Statistics**: Detailed tracking of quiz performance

### Daily Learning
- **Word of the Day**: Learn a new word each day
- **Daily Dashboard**: Track your daily progress and goals
- **Customizable Notifications**: Set reminders for daily practice
- **Progress Tracking**: Monitor your learning journey

### User Experience
- **Dynamic Voice Selection**: Automatically selects appropriate voice for target language
- **Text Scrolling**: Smooth scrolling for long words and phrases
- **Intuitive Navigation**: Easy access to all features
- **Settings Customization**: Personalize your learning experience
- **Language Pair Selection**: Choose your source and target languages

## Technical Details

### Architecture
- SwiftUI-based interface
- MVVM architecture pattern
- Persistent storage using @AppStorage
- Comprehensive test suite

### Data Management
- JSON-based word database
- Support for multiple language formats
- Fallback mechanisms for data loading
- Efficient state management

### Testing
- Unit tests for core functionality
- UI tests for interface components
- Model validation tests
- Achievement system tests
- Quiz functionality tests

## Requirements
- watchOS 9.0+
- Xcode 14.0+
- Swift 5.7+

## Installation
1. Clone the repository
2. Open the project in Xcode
3. Build and run on your Apple Watch or simulator

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details 