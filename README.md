# MAD Word Guessing Game

A complete Flutter mobile app that challenges players to guess secret words while managing points, attempts, and time. Built with Material 3 design and responsive layout.

## 🎯 Features

### Core Game Features
- **Word Guessing**: Players guess secret words fetched from APIs
- **Point System**: Start with 100 points, lose 10 points per wrong guess
- **Attempts**: 10 attempts per word with game over when exhausted
- **Timer**: Track completion time for leaderboard ranking
- **Levels**: Progress through levels with increasing difficulty

### Hints & Clues
- **Letter Occurrence**: Pay 5 points to see how many times a letter appears
- **Word Length**: Pay 5 points to reveal the word length
- **Rhymes & Synonyms**: Get hints after 5 failed attempts (free)

### User Experience
- **Onboarding**: Name collection with SharedPreferences storage
- **Home Screen**: Game stats, start new game, leaderboard access
- **Game Screen**: Interactive word guessing with real-time feedback
- **Leaderboard**: Global rankings with scores and completion times
- **Responsive Design**: Works on mobile, tablet, and desktop

## 🛠️ Technical Implementation

### Architecture
```
lib/
├── constants/          # App constants and configuration
├── models/            # Data models (Player, GameState, LeaderboardEntry)
├── services/          # API services and business logic
├── screens/           # UI screens (Onboarding, Home, Game, Leaderboard)
├── widgets/           # Reusable UI components
└── utils/             # Helper functions and utilities
```

### Dependencies
- `shared_preferences`: Local data storage
- `http`: API communication
- `provider`: State management

### APIs Used
- **Random Word API**: https://random-word-api.herokuapp.com/word
- **API Ninjas**: https://api.api-ninjas.com/v1/randomword (alternative)
- **Datamuse**: https://api.datamuse.com/words (for rhymes/synonyms)

## 🎮 Game Rules

1. **Start**: Player begins with 100 points and 10 attempts
2. **Guessing**: Enter word guesses to find the secret word
3. **Penalties**: Wrong guesses cost 10 points
4. **Hints**: Use points to get letter occurrences or word length
5. **Free Hints**: After 5 attempts, get rhymes/synonyms for free
6. **Game Over**: When points reach 0 or attempts exhausted
7. **Success**: Correct guess advances to next level

## 🏆 Scoring System

- **Points**: Start with 100, lose 10 per wrong guess
- **Timer**: Completion time tracked for leaderboard
- **Levels**: Higher levels = more complex words
- **Leaderboard**: Global rankings by score and time

## 📱 Screens

### Onboarding Screen
- Welcome message and app introduction
- Name input with validation
- Beautiful gradient background
- Material 3 design elements

### Home Screen
- Player stats display (level, points, games won)
- Action buttons (Start Game, Leaderboard, How to Play)
- Responsive layout for different screen sizes
- Settings access

### Game Screen
- Real-time game stats (points, attempts, timer)
- Word display with masking
- Guess input with validation
- Hint buttons with cost display
- Game over/success dialogs

### Leaderboard Screen
- Global rankings with player names
- Score and completion time display
- Medal icons for top 3 players
- Refresh functionality

## 🎨 Design Features

- **Material 3**: Modern design system with dynamic colors
- **Responsive**: Adapts to mobile, tablet, and desktop screens
- **Gradient Backgrounds**: Beautiful color transitions
- **Card-based Layout**: Clean, organized information display
- **Interactive Elements**: Smooth animations and feedback
- **Accessibility**: Proper contrast and touch targets

## 🚀 Getting Started

1. **Prerequisites**
   - Flutter SDK (3.5.3+)
   - Dart SDK
   - Android Studio / VS Code

2. **Installation**
   ```bash
   git clone <repository-url>
   cd my_mess
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

4. **Build for Production**
   ```bash
   flutter build apk --release
   flutter build ios --release
   ```

## 📊 Project Structure

### Models
- `Player`: User data with stats and progress
- `GameState`: Current game state with word, points, attempts
- `LeaderboardEntry`: Score entries for global rankings

### Services
- `GameProvider`: State management with Provider pattern
- `WordApiService`: API calls for random words and hints
- `LeaderboardService`: Score submission and retrieval
- `StorageHelper`: SharedPreferences wrapper for data persistence

### Screens
- `OnboardingScreen`: First-time user experience
- `HomeScreen`: Main menu with game options
- `GameScreen`: Core gameplay interface
- `LeaderboardScreen`: Global rankings display

### Widgets
- `GameStats`: Points, attempts, and timer display
- `GuessInput`: Word guessing input field
- `HintButtons`: Hint purchase and usage interface
- `GameTimer`: Real-time timer display

## 🔧 Configuration

### API Keys
Update API keys in `lib/services/word_api_service.dart`:
```dart
static const String _apiNinjasKey = 'YOUR_API_KEY';
```

### Constants
Modify game rules in `lib/constants/app_constants.dart`:
```dart
static const int initialPoints = 100;
static const int maxAttempts = 10;
static const int wrongGuessPenalty = 10;
```

## 🧪 Testing

The app includes comprehensive error handling:
- Network failure fallbacks
- API timeout handling
- Input validation
- State management error recovery

## 📈 Future Enhancements

- [ ] Sound effects and music
- [ ] Achievement system
- [ ] Daily challenges
- [ ] Social features
- [ ] Offline mode
- [ ] Multiple languages
- [ ] Custom word lists

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Built with ❤️ for the Flutter community.

---

**MAD Word Guessing Game** - Challenge your vocabulary and compete globally! 🎯