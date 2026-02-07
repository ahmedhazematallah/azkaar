# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Azkaar** is a Flutter mobile/web application for daily Islamic Azkar (supplications). It features a social media-style vertical scroll interface (like TikTok/Shorts) with a dark emerald theme and glassmorphism UI.

## Development Commands

### Build Commands
```bash
# Run the app in debug mode
flutter run

# Build for web release
flutter build web

# Build Android APK (release)
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release
```

### Development Commands
```bash
# Get dependencies
flutter pub get

# Run linting
flutter analyze

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Hot reload during development
flutter run --hot

# Generate app icons (configured in pubspec.yaml)
flutter pub run flutter_launcher_icons:main
```

## Architecture

### Project Structure
```
lib/
├── main.dart              # Main application (UI, state, settings)
└── data/
    └── azkar_data.dart    # Zikr data model and supplications list
```

### State Management
The app uses simple StatefulWidget with `setState` - no external state management libraries. State is persisted via `SharedPreferences`:
- `font_size` (double): User's preferred text size (18.0 - 40.0)
- `show_counter` (bool): Whether counter mode is enabled (default: false)
- `language` (String): UI language (Arabic, English, French, German, Japanese, Chinese)

### Key Classes

**`AzkarFeedPage`** (`main.dart:33-401`)
- Main screen with vertical PageView
- Handles settings modal, font scaling, progress tracking
- Contains inline `_translations` Map for 6-language localization

**`AzkarCard`** (`main.dart:403-594`)
- Individual zikr card with glassmorphism design
- Counter logic with animated visual feedback
- Uses `flutter_animate` for entrance animations

**`Zikr`** (`data/azkar_data.dart:1-15`)
- Data model: text, translation, description, count, category
- Default count is 1, default category is "عام"

### UI Design System
- **Theme**: Dark emerald (`Color(0xFF064D3B)`) with gold accents (`Color(0xFFC5A358)`)
- **Typography**: Google Fonts Amiri for Arabic text
- **Effects**: Glassmorphism via `BackdropFilter` with `ImageFilter.blur`
- **Progress**: Pie chart from `fl_chart` in top-left corner

### Two Operating Modes
1. **Counter Mode** (`show_counter: true`): User taps circular counter to increment; must reach target count to mark done
2. **Scroll Mode** (`show_counter: false`): Zikr automatically marked complete when scrolled into view

### Important Implementation Details
- PageView uses `ValueKey('zikr_${index}_$_resetVersion')` to force widget rebuild when resetting progress
- `_isScrollingToStart` flag prevents scroll events from marking items during animated reset
- Arabic text uses `Directionality(textDirection: TextDirection.rtl)` for proper rendering
- Settings modal uses `StatefulBuilder` to allow independent modal state updates
