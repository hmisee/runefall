# Design Document: Game Completion and Progression

## Overview

This design implements win/loss detection, UI enhancements, and a multi-level progression system for Runefall. The system adds game state management, a preview system for upcoming runes, modified gravity behavior, pause functionality, and persistent level progression.

The design follows Godot's scene-based architecture with clear separation between game logic (GameBoard), UI management (GameUI), state management (GameState), and persistence (SaveManager). The implementation leverages Godot's signal system for loose coupling between components.

## Architecture

### Component Structure

```
Main (Node2D)
├── GameState (Node) - Manages game state and level progression
├── GameBoard (Node2D) - Core game logic
├── GameUI (CanvasLayer) - UI overlay for messages and preview
├── MainMenu (CanvasLayer) - Level selection and game start
├── PauseMenu (CanvasLayer) - Pause overlay
└── SaveManager (Node) - Handles persistence
```

### State Machine

The game operates with the following states:

- **MENU**: Main menu displayed, no active game
- **PLAYING**: Active gameplay with falling runes
- **PAUSED**: Gameplay frozen, pause menu visible
- **WIN**: Level completed successfully
- **LOSS**: Game over condition met
- **TRANSITION**: Brief state between levels

### Signal Flow

```
GameBoard signals:
  - win_condition_met()
  - loss_condition_met()
  - elements_remaining_changed(count)

GameState signals:
  - state_changed(new_state)
  - level_started(level_number)
  - level_completed(level_number)

MainMenu signals:
  - level_selected(level_number)
  - quit_requested()

PauseMenu signals:
  - resume_requested()
  - main_menu_requested()
```

## Components and Interfaces

### GameState Component

Manages overall game state and level progression.

```gdscript
class_name GameState
extends Node

enum State { MENU, PLAYING, PAUSED, WIN, LOSS, TRANSITION }

var current_state: State = State.MENU
var current_level: int = 1
var max_unlocked_level: int = 1
const MAX_LEVELS: int = 3

signal state_changed(new_state: State)
signal level_started(level_number: int)
signal level_completed(level_number: int)

func change_state(new_state: State) -> void
func start_level(level_number: int) -> void
func complete_level() -> void
func fail_level() -> void
func pause_game() -> void
func resume_game() -> void
func return_to_menu() -> void
```

### GameBoard Modifications

Extends existing GameBoard with win/loss detection and element-only gravity.

```gdscript
# New signals
signal win_condition_met()
signal loss_condition_met()
signal elements_remaining_changed(count: int)

# New properties
var initial_element_count: int = 10
var next_rune_pair_data: Dictionary = {}
var game_active: bool = true

# New methods
func initialize_level(element_count: int) -> void
func check_win_condition() -> void
func check_spawn_availability() -> bool
func apply_gravity_runes_only() -> void
func generate_next_pair_data() -> Dictionary
func get_element_count() -> int
func stop_game() -> void
```

### GameUI Component

Displays game messages, next rune preview, and level information.

```gdscript
class_name GameUI
extends CanvasLayer

@onready var message_label: Label
@onready var preview_container: Control
@onready var level_label: Label
@onready var elements_label: Label

func show_message(text: String, duration: float = 0.0) -> void
func hide_message() -> void
func update_preview(rune1_type: int, rune2_type: int, rotation: int) -> void
func update_level_display(level: int) -> void
func update_elements_count(count: int) -> void
```

### MainMenu Component

Provides level selection interface with unlock state visualization.

```gdscript
class_name MainMenu
extends CanvasLayer

@onready var level_buttons_container: VBoxContainer
var level_buttons: Array[Button] = []

signal level_selected(level_number: int)
signal quit_requested()

func initialize(max_unlocked: int) -> void
func update_unlock_state(max_unlocked: int) -> void
func show_menu() -> void
func hide_menu() -> void
```

### PauseMenu Component

Simple pause overlay with continue and quit options.

```gdscript
class_name PauseMenu
extends CanvasLayer

@onready var continue_button: Button
@onready var main_menu_button: Button

signal resume_requested()
signal main_menu_requested()

func show_pause() -> void
func hide_pause() -> void
```

### SaveManager Component

Handles persistent storage of level unlock state.

```gdscript
class_name SaveManager
extends Node

const SAVE_PATH = "user://runefall_save.json"

func save_progress(max_unlocked_level: int) -> void
func load_progress() -> int
func has_save_file() -> bool
```

## Data Models

### Level Configuration

```gdscript
const LEVEL_CONFIG = {
	1: { "elements": 10, "name": "Calm Beginnings" },
	2: { "elements": 15, "name": "Rising Chaos" },
	3: { "elements": 20, "name": "Elemental Storm" }
}
```

### Next Rune Pair Data

```gdscript
{
	"rune1_type": int,  # 0-3 for FIRE, WATER, EARTH, AIR
	"rune2_type": int,  # 0-3 for FIRE, WATER, EARTH, AIR
	"rotation": int     # 0-3 for rotation state
}
```

### Save Data Structure

```gdscript
{
	"max_unlocked_level": int,
	"version": "1.0"
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Win state transition on element clear

*For any* game board state, when all elements are removed from the board, the game state should transition to WIN.

**Validates: Requirements 1.1**

### Property 2: Game end stops spawning

*For any* game end state (WIN or LOSS), the game board should stop spawning new rune pairs and reject any spawn attempts.

**Validates: Requirements 1.2, 2.2**

### Property 3: Win condition checked after match clearing

*For any* game board state where a match is cleared, the win condition check should be invoked immediately after the match removal.

**Validates: Requirements 1.4**

### Property 4: Loss state transition on blocked spawn

*For any* game board state where the spawn position is occupied, attempting to spawn a new rune pair should transition the game state to LOSS.

**Validates: Requirements 2.1**

### Property 5: Spawn availability checked before placement

*For any* spawn attempt, the game board should verify spawn position availability before creating a new rune pair.

**Validates: Requirements 2.4**

### Property 6: Preview shows next pair

*For any* game state with an active rune pair, the preview data should match the rune pair that becomes active when the current pair locks.

**Validates: Requirements 3.1**

### Property 7: Preview updates on pair activation

*For any* rune pair activation, the preview should update to show the following pair's data (types and rotation).

**Validates: Requirements 3.2**

### Property 8: Preview contains complete data

*For any* preview state, the preview data should include both rune types and rotation state.

**Validates: Requirements 3.3**

### Property 9: Gravity affects only runes

*For any* game board state after match clearing, applying gravity should move runes downward into empty spaces while keeping all elements in their original positions.

**Validates: Requirements 4.1, 4.2, 4.4**

### Property 10: Runes fall one cell per gravity step

*For any* rune positioned above empty space, a single gravity step should move the rune down by exactly one grid cell.

**Validates: Requirements 4.3**

### Property 11: Pause freezes game logic

*For any* game board state, when the game is paused, the game timer and all piece movement should be frozen until resume.

**Validates: Requirements 5.2**

### Property 12: Level element count increases with level number

*For any* two levels where level A has a lower number than level B, level A should spawn fewer initial elements than level B.

**Validates: Requirements 6.3**

### Property 13: Level initialization spawns correct element count

*For any* level number, starting that level should spawn exactly the element count specified in the level configuration.

**Validates: Requirements 6.2**

### Property 14: Winning unlocks next level

*For any* level that is not the final level, completing that level should increment the max unlocked level by one.

**Validates: Requirements 6.4**

### Property 15: Locked levels are visually distinct

*For any* level number greater than max unlocked level, the main menu should display that level as disabled or locked.

**Validates: Requirements 7.3**

### Property 16: Level selection starts correct level

*For any* unlocked level selected from the main menu, the game should initialize and start that specific level number.

**Validates: Requirements 7.4**

### Property 17: Save and load preserves unlock state

*For any* max unlocked level value, saving that value then loading should return the same max unlocked level value.

**Validates: Requirements 7.5, 9.1, 9.2**

### Property 18: Auto-progression after non-final level win

*For any* level that is not the final level, winning that level should automatically start the next level after the win message timer expires.

**Validates: Requirements 8.2**

### Property 19: Save triggered on level completion

*For any* level completion (win state), the save manager should be called to persist the current unlock state.

**Validates: Requirements 9.4**


## Error Handling

### Save/Load Failures

**Scenario**: File system errors during save or load operations

**Handling**:
- SaveManager wraps file operations in try-catch blocks
- On save failure: Log error, continue gameplay (non-critical)
- On load failure: Default to level 1 unlocked, log warning
- Use Godot's `FileAccess.get_open_error()` to detect issues

```gdscript
func load_progress() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 1  # Default: only level 1 unlocked
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Failed to open save file: " + str(FileAccess.get_open_error()))
		return 1
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_warning("Failed to parse save file")
		return 1
	
	var data = json.data
	return data.get("max_unlocked_level", 1)
```

### Invalid Level Selection

**Scenario**: Attempting to start a level that doesn't exist or is locked

**Handling**:
- GameState validates level number against MAX_LEVELS constant
- Validates level is unlocked before starting
- Falls back to level 1 if invalid

```gdscript
func start_level(level_number: int) -> void:
	if level_number < 1 or level_number > MAX_LEVELS:
		push_warning("Invalid level number: " + str(level_number))
		level_number = 1
	
	if level_number > max_unlocked_level:
		push_warning("Attempted to start locked level: " + str(level_number))
		return
	
	current_level = level_number
	change_state(State.PLAYING)
	level_started.emit(level_number)
```

### State Transition Errors

**Scenario**: Invalid state transitions (e.g., pause while in menu)

**Handling**:
- GameState validates transitions before applying
- Ignore invalid transitions with warning
- Maintain state consistency

```gdscript
func pause_game() -> void:
	if current_state != State.PLAYING:
		push_warning("Cannot pause from state: " + str(current_state))
		return
	
	change_state(State.PAUSED)
```

### Spawn Position Blocked at Level Start

**Scenario**: Level configuration spawns so many elements that spawn position is blocked immediately

**Handling**:
- GameBoard checks spawn availability after element initialization
- If blocked, remove elements from top rows until spawn is clear
- Log warning about configuration issue

```gdscript
func initialize_level(element_count: int) -> void:
	clear_board()
	spawn_initial_elements(element_count)
	
	# Ensure spawn position is clear
	if not check_spawn_availability():
		push_warning("Spawn blocked after initialization, clearing top rows")
		clear_top_rows(2)
```

### Missing UI Nodes

**Scenario**: Scene structure doesn't match expected node paths

**Handling**:
- Use `@onready` with null checks in `_ready()`
- Gracefully degrade functionality if UI missing
- Log errors for debugging

```gdscript
func _ready():
	if message_label == null:
		push_error("GameUI: message_label not found")
	if preview_container == null:
		push_error("GameUI: preview_container not found")
```

## Testing Strategy

### Dual Testing Approach

This feature requires both unit tests and property-based tests for comprehensive coverage:

- **Unit tests**: Verify specific examples, edge cases, and UI interactions
- **Property tests**: Verify universal properties across randomized game states

### Property-Based Testing

We'll use [GdUnit4](https://github.com/MikeSchulze/gdUnit4) with its fuzzer support for property-based testing in GDScript. Each property test will run a minimum of 100 iterations with randomized inputs.

**Test Configuration**:
```gdscript
# Each property test uses fuzzer with min 100 iterations
func test_property_example() -> void:
	var fuzzer = Fuzzers.rangei(1, 100)
	await assert_that(fuzzer).run_test(100, func(value):
		# Property test logic
		return true
	)
```

**Property Test Tags**:
Each property-based test must include a comment tag referencing the design property:

```gdscript
# Feature: game-completion-and-progression, Property 1: Win state transition on element clear
func test_win_state_on_element_clear() -> void:
	# Test implementation
```

### Unit Test Coverage

**Win/Loss Detection** (`test_game_state.gd`):
- Example: Clearing last element triggers win message
- Example: Blocked spawn triggers loss message
- Example: Win on final level shows congratulations message
- Edge case: No saved state defaults to level 1 unlocked

**Preview System** (`test_preview.gd`):
- Example: Preview positioned outside board bounds (800x800 board, preview at x > 800)
- Example: Preview updates when pair locks

**Pause Functionality** (`test_pause.gd`):
- Example: Escape key shows pause menu
- Example: Continue button resumes game
- Example: Main menu button returns to menu
- Example: Pause menu shows "Continue" and "Main Menu" options

**Level System** (`test_levels.gd`):
- Example: Game starts showing main menu
- Example: Main menu displays level buttons
- Example: Three levels are configured
- Example: Win message displays for 3 seconds before auto-progression
- Edge case: Winning final level shows final congratulations
- Edge case: Final level provides return to menu option

**State Persistence** (`test_save_manager.gd`):
- Edge case: Missing save file defaults to level 1
- Example: Save file contains version field

### Property-Based Test Coverage

**Property 1: Win state transition** (`test_win_condition_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 1: Win state transition on element clear
# Generate random board states with varying element counts
# Clear all elements, verify state transitions to WIN
```

**Property 2: Game end stops spawning** (`test_spawn_control_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 2: Game end stops spawning
# Generate random end states (WIN/LOSS)
# Verify spawn attempts are rejected
```

**Property 3: Win check after match** (`test_match_checking_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 3: Win condition checked after match clearing
# Generate random board states with matches
# Clear matches, verify win check is invoked
```

**Property 4: Loss on blocked spawn** (`test_loss_condition_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 4: Loss state transition on blocked spawn
# Generate random board states with blocked spawn positions
# Attempt spawn, verify LOSS state transition
```

**Property 5: Spawn availability check** (`test_spawn_validation_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 5: Spawn availability checked before placement
# Generate random board states
# Verify spawn check occurs before pair creation
```

**Property 6: Preview accuracy** (`test_preview_accuracy_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 6: Preview shows next pair
# Generate random rune pair sequences
# Verify preview data matches next active pair
```

**Property 7: Preview updates** (`test_preview_updates_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 7: Preview updates on pair activation
# Generate random game sequences
# Track preview updates, verify timing
```

**Property 8: Preview data completeness** (`test_preview_data_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 8: Preview contains complete data
# Generate random preview states
# Verify all required fields present (rune1_type, rune2_type, rotation)
```

**Property 9: Gravity runes only** (`test_gravity_behavior_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 9: Gravity affects only runes
# Generate random board states with runes and elements
# Apply gravity, verify only runes move and elements stay
```

**Property 10: Rune fall distance** (`test_rune_fall_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 10: Runes fall one cell per gravity step
# Generate random rune positions above empty space
# Apply single gravity step, verify movement is exactly one cell
```

**Property 11: Pause freezes logic** (`test_pause_freeze_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 11: Pause freezes game logic
# Generate random game states
# Pause, verify timers and movement frozen
```

**Property 12: Level difficulty progression** (`test_level_difficulty_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 12: Level element count increases with level number
# For all level pairs (A, B) where A < B
# Verify element_count(A) < element_count(B)
```

**Property 13: Level initialization** (`test_level_init_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 13: Level initialization spawns correct element count
# Generate random level numbers (1-3)
# Start level, count elements, verify matches config
```

**Property 14: Unlock progression** (`test_unlock_progression_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 14: Winning unlocks next level
# Generate random non-final level numbers
# Complete level, verify max_unlocked increments by 1
```

**Property 15: Locked level display** (`test_locked_display_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 15: Locked levels are visually distinct
# Generate random max_unlocked values
# Verify levels > max_unlocked are disabled in UI
```

**Property 16: Level selection** (`test_level_selection_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 16: Level selection starts correct level
# Generate random unlocked level numbers
# Select level, verify correct level initializes
```

**Property 17: Save/load round-trip** (`test_persistence_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 17: Save and load preserves unlock state
# Generate random max_unlocked values (1-3)
# Save then load, verify value preserved
```

**Property 18: Auto-progression** (`test_auto_progression_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 18: Auto-progression after non-final level win
# Generate random non-final level numbers
# Win level, wait for timer, verify next level starts
```

**Property 19: Save on completion** (`test_save_trigger_pbt.gd`):
```gdscript
# Feature: game-completion-and-progression, Property 19: Save triggered on level completion
# Generate random level completion scenarios
# Verify save manager called after win state
```

### Test Execution

Run all tests with:
```bash
# Run all tests
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test

# Run specific test suite
godot --headless -s addons/gdUnit4/bin/GdUnitCmdTool.gd --test tests/test_win_condition_pbt.gd
```

### Integration Testing

Beyond unit and property tests, manual integration testing should verify:
- Complete gameplay flow from menu through multiple levels
- Save/load persistence across game restarts
- UI responsiveness and visual feedback
- Pause/resume during active gameplay
- Edge cases like rapid input during state transitions

