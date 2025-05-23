# Language Byte Watch App

A watchOS application for learning vocabulary in multiple languages with a clean, intuitive interface.

![Language Byte - WatchOS App](app_screenshot.png)

## Features

### Multi-Language Support
- Switch between multiple language pairs (English-Spanish, English-French, etc.)
- Persistent language selection across app launches
- Comprehensive vocabulary across different categories

### Text-to-Speech
- Dynamic voice selection based on target language
- Customizable voice options for each language
- Automatic fallback to system voices when needed

### User Interface
- Clean, simple watchOS interface optimized for small screens
- Animated transitions between language selections
- Scrollable main view with quick access to all features
- Clear language indicator showing current selection

### Learning Tools
- Mark words as favorites for focused study
- Categorized vocabulary (verbs, food, family, colors, numbers, phrases)
- Tap to toggle between source and target languages
- History tracking of viewed words
- Daily dashboard with progress tracking
- Word of the Day feature for regular practice

### Customization
- User preferences saved automatically
- Voice selection per language
- Appearance customization options
- Customizable daily notification schedule
- Daily word notifications with time selection

### Notifications & Reminders
- Daily Word of the Day notifications
- Customizable notification time
- Enable/disable notifications through Settings
- Clear notification status indicators
- Intelligent notification scheduling

## Setup Instructions

### Installation
1. Clone the repository
2. Open the project in Xcode
3. Build and run on a watchOS simulator or device

### Required Versions
- iOS 15.0+
- watchOS 8.0+
- Xcode 13.0+
- Swift 5.5+

## App Structure

### Models
- `WordPair`: A word pair with foreign word, translation, and category
- `Language`: A language with code, name, and speech code
- `LanguagePair`: A pair of languages with word pairs

### Views
- `MainView`: Entry point with navigation to all major features
- `WordView`: Main learning interface showing vocabulary
- `SettingsView`: Configure app preferences and options
- `LanguageSelectionView`: Select language pair for study
- `FavoritesView`: View and manage favorite words
- `DailyDashboardView`: Track progress and view Word of the Day

### View Models
- `WordViewModel`: Central data model managing words and app state
- `LanguageDataManager`: Handles loading and organizing language data

## Data Structure

The app uses a JSON structure for language data:
- `multilingual_words.json`: Contains vocabulary in multiple languages
- Organized by language pairs and categories
- Easily extensible for adding new words and languages

## Recent Improvements

- Added Word of the Day feature with persistent storage
- Implemented daily notification system with customizable scheduling
- Created DailyDashboardView to track learning progress
- Added notification settings with time picker and toggle controls
- Enhanced UI with better feedback for notification status
- Improved overall app structure and navigation flow
- Streamlined app startup by replacing ContentView with MainView

## Future Development

Planned enhancements:
- Gamification features with points and streaks for daily learning
- Enhanced statistics tracking with progress visualization
- Multiple Words of the Day with difficulty levels
- AI-powered adaptive learning based on user performance
- Interactive learning modes beyond simple word display
- Advanced notification options (weekly reviews, quizzes)
- Extension to iPad and iPhone platforms
- Offline voice support for environments without internet
- Accessibility enhancements for diverse user needs
- Multi-user support for family or classroom settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 