# Language Byte Watch App

A watchOS application for learning vocabulary in multiple languages with a clean, intuitive interface.

![Language Byte - WatchOS App](app_screenshot.png)

## Features

### Multi-Language Support
- Switch between multiple language pairs (English-Spanish, English-French, etc.)
- Persistent language selection across app launches
- Comprehensive vocabulary across different categories

### Experience Points (XP) System
- Gamified learning experience with XP rewards for activities
- Level progression system with dynamic level titles
- XP statistics with detailed progress tracking
- Level-up celebrations with animations and confetti effects
- Streak bonuses for consistent correct answers
- Visual progress indicators showing path to next level

### Quiz and Achievements
- Comprehensive quiz system with score tracking and persistence
- Streak counting and best streak tracking
- Visual feedback for correct/incorrect answers
- Achievement system with multiple categories:
  * Beginner achievements (Quiz Novice, Language Apprentice)
  * Streak-based achievements (On Fire, Unstoppable)
  * Accuracy-based achievements (Sharp Mind, Brainiac)
  * Mastery achievements (Dedicated Scholar, Language Master)
  * Special achievements (Comeback Kid, Quick Thinker)
  * XP-based achievements (Level 5 Reached, Dedicated Learner, First Steps, XP Champion, Word Master)
- Detailed quiz statistics and progress tracking
- Achievement display with custom icons and colors
- Exit confirmation to prevent accidental navigation

### Text-to-Speech
- Dynamic voice selection based on target language
- Customizable voice options for each language
- Automatic fallback to system voices when needed

### User Interface
- Clean, simple watchOS interface optimized for small screens
- Animated transitions between language selections
- Advanced text scrolling for long words/phrases with optimized cycling
- Intelligent display that only scrolls text when necessary
- Scrollable main view with quick access to all features
- Clear language indicator showing current selection
- Dedicated level view with detailed XP statistics
- Progress bars and visual indicators for level advancement

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

### Testing
- Comprehensive automated test suite
- Unit tests for models, managers, and view models
- Basic UI initialization tests
- Mock data for testing without external dependencies

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
- `QuizView`: Interactive quiz mode with scoring and achievements
- `QuizStatsView`: Detailed quiz statistics and achievements display
- `LevelView`: Display XP progress, level information, and statistics

### View Models
- `WordViewModel`: Central data model managing words and app state
- `LanguageDataManager`: Handles loading and organizing language data

### Managers
- `NotificationManager`: Handles scheduling of daily notifications
- `LanguageDataManager`: Manages language data loading and formatting
- `AchievementManager`: Manages achievement tracking and unlocking
- `XPManager`: Manages XP calculation, level progression, and notifications

### Tests
- `ModelTests`: Tests for data models and their behavior
- `ManagerTests`: Tests for managers and their functionality
- `WordViewModelTests`: Tests for the core view model logic
- `UITests`: Basic tests for view initialization
- `TestHelpers`: Helper methods and mock data for testing

## Data Structure

The app uses a JSON structure for language data:
- `multilingual_words.json`: Contains vocabulary in multiple languages
- Organized by language pairs and categories
- Easily extensible for adding new words and languages

## Recent Improvements

- Implemented comprehensive XP system with level progression
- Added XP-based achievements to reward learning milestones
- Created dedicated LevelView with detailed XP statistics
- Implemented level-up celebrations with animations and visual feedback
- Added streak bonuses for consistent correct answers in quizzes
- Previous improvements:
  * Implemented comprehensive quiz system with achievement tracking
  * Added persistent score and streak counting functionality
  * Created achievement system with multiple categories and custom icons
  * Enhanced DailyDashboardView with quiz statistics integration
  * Improved UI consistency across all views with standardized styling
  * Optimized button placement and navigation flow
  * Added exit confirmation for quiz mode to prevent accidental exits
  * Enhanced visual feedback for user interactions
  * Fixed quiz score reset functionality and state management
  * Enhanced text scrolling mechanism to display long words without truncation
  * Optimized animation cycles for faster text return when scrolling long content
  * Implemented context-aware text display that adapts to content length
  * Added Word of the Day feature with persistent storage
  * Implemented daily notification system with customizable scheduling
  * Created DailyDashboardView to track learning progress
  * Added notification settings with time picker and toggle controls
  * Enhanced UI with better feedback for notification status
  * Improved overall app structure and navigation flow
  * Streamlined app startup by replacing ContentView with MainView
  * Added comprehensive automated test suite to ensure code reliability

## Future Development

Planned enhancements:
- Advanced gamification features with season passes and premium achievements
- Enhanced statistics tracking with progress visualization
- Multiple Words of the Day with difficulty levels
- AI-powered adaptive learning based on user performance
- Interactive learning modes beyond simple word display
- Advanced notification options (weekly reviews, quizzes)
- Extension to iPad and iPhone platforms
- Offline voice support for environments without internet
- Accessibility enhancements for diverse user needs
- Multi-user support for family or classroom settings
- Expanded test coverage with snapshot and integration tests

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 