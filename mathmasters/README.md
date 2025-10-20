# MathQuest Kids — Flutter Maths Game (Offline + JSON)

A colourful, kid-friendly offline math quiz game built with Flutter. All questions are stored locally in a single JSON file and loaded at runtime.

## Features
- Player name entry and local persistence (SharedPreferences)
- Topic selection (multiple): Addition, Subtraction, Multiplication, Division, Fractions, Decimals
- 30 levels, 20 questions per level; unlock next level at 80%+
- Countdown timer per level: `max(60, 600 - (level-1)*15)`
- Multiple-choice gameplay with colourful feedback
- Summary screen with score and progression
- Local scoreboard (stored in SharedPreferences)
- Light/Dark theme toggle (Riverpod + SharedPreferences)
- Confetti on success (optional)

## Project Structure
```
lib/
	main.dart
	data/
		questions_loader.dart
	models/
		question.dart
		player.dart
	providers/
		quiz_provider.dart
		theme_provider.dart
		persistence_provider.dart
	screens/
		name_entry_screen.dart
		topic_select_screen.dart
		level_select_screen.dart
		quiz_screen.dart
		summary_screen.dart
		scoreboard_screen.dart
		settings_screen.dart
	widgets/
		question_card.dart
		option_button.dart
		timer_circle.dart
assets/
	questions.json
```

## Running
1. Install Flutter (stable) and run `flutter doctor`.
2. Get dependencies and run the app:

```
flutter pub get
flutter run
```

## Questions JSON Schema
All questions are stored in a single file at `assets/questions.json` in the following format:

```json
{
	"addition": {
		"level1": [
			{ "question": "5 + 3 = ?", "options": ["6","7","8","9"], "answerIndex": 2 }
		],
		"level2": [
			{ "question": "15 + 27 = ?", "options": ["32","42","43","40"], "answerIndex": 1 }
		]
	},
	"subtraction": { "level1": [ { "question": "8 - 5 = ?", "options": ["2","3","4","5"], "answerIndex": 1 } ] },
	"multiplication": { ... },
	"division": { ... },
	"fractions": { ... },
	"decimals": { ... }
}
```

- Each topic contains `level1`..`level30` arrays.
- Each question object has:
	- `question`: string
	- `options`: array of 4 strings
	- `answerIndex`: integer (0-3)

## Adding More Questions
- Open `assets/questions.json` and add more questions under the appropriate topic and level keys (e.g., `level3`, `level4`, ... up to `level30`).
- Ensure there are at most 20 questions per level; if more are present, the game will take the first 20 after shuffling.
- After editing, hot reload or rebuild to apply changes.

## Scoring
```
baseScore = correctAnswers * 100
timeBonus = floor(timeRemaining / 5)
totalScore = baseScore + timeBonus
```

## Notes
- All data is offline; no network calls.
- Persistence uses SharedPreferences for simplicity.
- You can swap to Hive later if you prefer typed boxes.
