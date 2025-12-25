# Liquid 2048 🎮✨

A beautiful 2048 game built with Flutter featuring a stunning **Liquid Glass** aesthetic with frosted glass effects, neon glows, and smooth animations.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## Features

### 🎯 Core Gameplay
- Classic 2048 sliding tile puzzle mechanics
- 4×4 grid with swipe controls (up, down, left, right)
- Tiles merge when same values collide
- Random new tiles (2 or 4) appear after each move
- Game ends when no valid moves remain
- Win condition: Reach 2048!

### 🎨 Liquid Glass UI
- **Frosted Glass Effects**: Beautiful translucent containers with blur
- **Neon Glows**: Dynamic glow effects that change with tile values
- **Gradient Backgrounds**: Smooth dark gradients with ambient lighting
- **Glass Reflections**: Subtle light reflections on tiles

### ✨ Animations
- Smooth tile slide transitions
- Bounce/scale animations on tile merge
- Fade-in animations for new tiles
- Animated background decorations

### 📱 Features
- **Score Tracking**: Current score and high score persistence
- **Undo Move**: Go back to previous state
- **Restart**: Start a new game anytime
- **Responsive Layout**: Adapts to portrait and landscape orientations
- **Haptic Feedback**: Tactile response on interactions

### 🏗️ Architecture
- **Clean Architecture**: Separation of UI, state management, and business logic
- **Riverpod**: Reactive state management
- **Pure Functions**: Game logic in `GameManager` class is fully testable
- **Unit Tests**: Comprehensive test coverage for game mechanics

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   └── services/
│       ├── haptic_service.dart        # Haptic feedback
│       ├── sound_service.dart         # Audio effects
│       └── theme_service.dart         # Theme customization
├── features/
│   ├── game/
│   │   ├── domain/
│   │   │   ├── tile.dart              # Tile model
│   │   │   ├── game_state.dart        # Game state model
│   │   │   └── game_manager.dart      # Pure game logic
│   │   └── presentation/
│   │       ├── providers/
│   │       │   └── game_provider.dart # Riverpod providers
│   │       ├── screens/
│   │       │   └── game_screen.dart   # Main game screen
│   │       └── widgets/
│   │           ├── game_grid.dart     # The 4x4 grid
│   │           ├── game_tile.dart     # Individual tile widget
│   │           ├── score_panel.dart   # Score display
│   │           ├── game_controls.dart # Undo/restart buttons
│   │           └── game_overlay.dart  # Win/lose overlays
│   └── home/
│       └── presentation/
│           └── home_screen.dart       # Home/title screen
└── shared/
    ├── theme/
    │   └── app_theme.dart             # Colors and theme
    └── widgets/
        └── liquid_glass_container.dart # Reusable glass widgets
```

## Getting Started

### Prerequisites
- Flutter SDK (3.10+)
- Dart SDK (3.0+)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/liquid_2048_game.git
cd liquid_2048_game
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running Tests

```bash
flutter test
```

## Game Logic

The game logic is implemented in `GameManager` as pure static functions:

```dart
// Start a new game
final state = GameManager.newGame();

// Make a move
final newState = GameManager.move(state, Direction.left);

// Check for valid moves
final hasValidMoves = GameManager.hasValidMoves(state.grid);

// Undo last move
final previousState = GameManager.undo(state);
```

## Tile Colors

Each tile value has a unique neon color scheme:

| Value | Color |
|-------|-------|
| 2 | Cyan |
| 4 | Blue |
| 8, 16 | Purple |
| 32, 64 | Pink |
| 128 | Orange |
| 256 | Yellow |
| 512 | Green |
| 1024, 2048 | Gold |

## Dependencies

- `flutter_riverpod` - State management
- `shared_preferences` - High score persistence
- `google_fonts` - Custom typography (Orbitron, Rajdhani)
- `audioplayers` - Sound effects (optional)
- `vibration` - Haptic feedback

## Screenshots

*Coming soon*

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Original 2048 game by Gabriele Cirulli
- Inspired by liquid glass design trends
- Built with Flutter ❤️
