# Language Byte Watch App

A comprehensive language learning companion for Apple Watch, featuring vocabulary building, interactive quizzes, progress tracking, and achievement systems.

![App Screenshot](screenshot.png)

## Features

### Core Functionality
- **Multi-Language Support**: Learn Spanish, French, German, Japanese, Chinese, and more
- **Interactive Quiz System**: Multiple question types with streak tracking
- **Daily Progress Dashboard**: Track your learning statistics and daily goals
- **Achievement System**: Unlock 10+ badges for various learning milestones
- **Smart Notifications**: Customizable daily reminders with Word of the Day
- **Speech Synthesis**: Hear pronunciations with authentic accents
- **Text Scrolling**: Automatic marquee effect for long words/phrases

### Recent Additions
- **Expanded Language Support**: Added Korean, Haitian Creole, and Portuguese
- **Quiz Achievements**: 
  - Streak-based: On Fire (5), Unstoppable (10)
  - Accuracy-based: Sharp Mind (80%), Perfect Recall (100%)
  - Special: Comeback Kid, Quick Thinker
- **Enhanced Testing Suite**:
  - Centralized mock classes
  - XCTest integration
  - ViewInspector for UI testing
- **Performance Improvements**:
  - Optimized text scrolling
  - Improved quiz state management
  - Enhanced voice selection logic

## Getting Started

### Prerequisites
- Xcode 15+
- watchOS 10+ compatible device
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `Language Byte.xcodeproj`
3. Add required packages:
   - ViewInspector (for testing)
4. Build and run on simulator or device

### Basic Usage
1. **Select Language Pair**:
   - Open Settings > Language Selection
   - Choose source and target languages

2. **Daily Practice**:
   - Receive Word of the Day via notification
   - Track progress in Daily Dashboard

3. **Quiz Mode**:
   - Test your knowledge in timed quizzes
   - Track streaks and accuracy
   - Unlock achievements as you progress

## Development Setup

### Testing
```bash
# Run all unit tests
xcodebuild test -scheme "Language_Byte_Tests"
```

### Key Components
- `WordViewModel`: Core business logic
- `QuizEngine`: Manages quiz state and scoring
- `AchievementManager`: Handles achievement tracking
- `LanguageDataManager`: Loads and processes language data

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

**Testing Guidelines**:
- Use centralized mocks from `QuizMocks.swift`
- Follow XCTest patterns
- Maintain 80%+ test coverage
- Validate all achievement conditions

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgements
- ViewInspector for SwiftUI testing
- Apple Speech Synthesis framework
- Word data from Open Multilingual Wordnet 