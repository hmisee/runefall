# Requirements Document

## Introduction

This document specifies requirements for game completion detection, progression system, and UI enhancements for Runefall. The features include win/loss conditions, next rune preview, element behavior changes, menu system, and multi-level progression.

## Glossary

- **Game_Board**: The 8x16 grid where runes and elements exist
- **Rune**: A colored square that falls in pairs (Fire, Water, Earth, Air types)
- **Element**: A colored circle that needs to be calmed (Fire, Water, Earth, Air types)
- **Rune_Pair**: Two connected runes that fall together and can be rotated
- **Match**: Four or more adjacent items of the same type (horizontally or vertically)
- **Active_Rune_Pair**: The currently falling rune pair controlled by the player
- **Next_Rune_Preview**: UI element showing the upcoming rune pair
- **Level**: A game stage with a specific number of initial elements
- **Pause_Menu**: UI overlay shown when player pauses the game
- **Main_Menu**: UI screen for level selection and game options
- **Game_Session**: A single playthrough of one level from start to completion

## Requirements

### Requirement 1: Win Condition Detection

**User Story:** As a player, I want the game to end when I clear all elements, so that I know I've successfully completed the level

#### Acceptance Criteria

1. WHEN all elements are cleared from the Game_Board, THE Game_Session SHALL transition to win state
2. WHEN the Game_Session transitions to win state, THE Game_Board SHALL stop spawning new Rune_Pairs
3. WHEN the Game_Session transitions to win state, THE Game_Board SHALL display "The shaman successfully calmed down all the elements"
4. THE Game_Board SHALL check for win condition after each Match is cleared

### Requirement 2: Loss Condition Detection

**User Story:** As a player, I want the game to end when I can't place new runes, so that I know the elements have overwhelmed me

#### Acceptance Criteria

1. WHEN a new Rune_Pair cannot be placed at the spawn position, THE Game_Session SHALL transition to loss state
2. WHEN the Game_Session transitions to loss state, THE Game_Board SHALL stop spawning new Rune_Pairs
3. WHEN the Game_Session transitions to loss state, THE Game_Board SHALL display "Game Over - The elements remain angry"
4. THE Game_Board SHALL check spawn position availability before placing each new Rune_Pair

### Requirement 3: Next Rune Preview

**User Story:** As a player, I want to see which runes will appear next, so that I can plan my strategy

#### Acceptance Criteria

1. THE Next_Rune_Preview SHALL display the next Rune_Pair before it becomes the Active_Rune_Pair
2. WHEN a Rune_Pair becomes the Active_Rune_Pair, THE Next_Rune_Preview SHALL update to show the following Rune_Pair
3. THE Next_Rune_Preview SHALL display rune colors and orientation
4. THE Next_Rune_Preview SHALL be positioned outside the Game_Board area

### Requirement 4: Element Gravity Behavior

**User Story:** As a player, I want only runes to fall when matches are cleared, so that elements stay in place until I clear them

#### Acceptance Criteria

1. WHEN a Match is cleared, THE Game_Board SHALL apply gravity only to Runes
2. THE Game_Board SHALL NOT apply gravity to Elements
3. WHEN a Rune is above empty space, THE Game_Board SHALL move the Rune downward by one cell per gravity step
4. WHEN an Element is above empty space, THE Game_Board SHALL keep the Element in its current position

### Requirement 5: Pause Menu

**User Story:** As a player, I want to pause the game and access options, so that I can take breaks or adjust settings

#### Acceptance Criteria

1. WHEN the player presses the Escape key during gameplay, THE Game_Session SHALL pause and display the Pause_Menu
2. WHEN the Game_Session is paused, THE Game_Board SHALL stop all game logic updates
3. THE Pause_Menu SHALL display "Continue" and "Main Menu" options
4. WHEN the player selects "Continue" from the Pause_Menu, THE Game_Session SHALL resume gameplay
5. WHEN the player selects "Main Menu" from the Pause_Menu, THE Game_Session SHALL transition to the Main_Menu

### Requirement 6: Level System

**User Story:** As a player, I want to progress through multiple levels of increasing difficulty, so that the game remains challenging

#### Acceptance Criteria

1. THE Game_Session SHALL support at least 3 distinct levels
2. WHEN a Level starts, THE Game_Board SHALL spawn a level-specific number of initial Elements
3. THE Game_Board SHALL spawn more initial Elements in higher-numbered levels than lower-numbered levels
4. WHEN the player wins a Level, THE Game_Session SHALL unlock the next Level
5. WHEN the player wins the final Level, THE Game_Session SHALL display a congratulations message

### Requirement 7: Main Menu

**User Story:** As a player, I want a main menu to select levels and manage my game, so that I can control my gameplay experience

#### Acceptance Criteria

1. WHEN the game starts, THE Game_Session SHALL display the Main_Menu
2. THE Main_Menu SHALL display available Level options
3. THE Main_Menu SHALL display locked levels as unavailable
4. WHEN the player selects an unlocked Level from the Main_Menu, THE Game_Session SHALL start that Level
5. THE Main_Menu SHALL persist level unlock state between game sessions

### Requirement 8: Level Progression

**User Story:** As a player, I want to automatically advance to the next level after winning, so that I can continue playing seamlessly

#### Acceptance Criteria

1. WHEN the player wins a Level that is not the final Level, THE Game_Session SHALL display the win message for 3 seconds
2. WHEN the win message display time elapses, THE Game_Session SHALL automatically start the next Level
3. WHEN the player wins the final Level, THE Game_Session SHALL display "Congratulations! You have mastered all elements!" 
4. WHEN the final level congratulations message is displayed, THE Game_Session SHALL provide an option to return to the Main_Menu

### Requirement 9: Game State Persistence

**User Story:** As a player, I want my progress to be saved, so that I can continue from where I left off

#### Acceptance Criteria

1. WHEN a Level is unlocked, THE Game_Session SHALL save the unlock state to persistent storage
2. WHEN the game starts, THE Game_Session SHALL load the saved unlock state from persistent storage
3. IF no saved state exists, THEN THE Game_Session SHALL unlock only Level 1
4. THE Game_Session SHALL save state after each Level completion
