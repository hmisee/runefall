class_name GameState
extends Node

## GameState manages overall game state and level progression
## Implements state machine with validation and signals for state changes

enum State { MENU, PLAYING, PAUSED, WIN, LOSS, TRANSITION }

# Current game state
var current_state: State = State.MENU

# Level tracking
var current_level: int = 1
var max_unlocked_level: int = 1
const MAX_LEVELS: int = 3

# Signals for state changes and level events
signal state_changed(new_state: State)
signal level_started(level_number: int)
signal level_completed(level_number: int)

## Change the current game state with validation
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	state_changed.emit(new_state)

## Start a specific level with validation
func start_level(level_number: int) -> void:
	# Validate level number
	if level_number < 1 or level_number > MAX_LEVELS:
		push_warning("Invalid level number: " + str(level_number))
		level_number = 1
	
	# Validate level is unlocked
	if level_number > max_unlocked_level:
		push_warning("Attempted to start locked level: " + str(level_number))
		return
	
	current_level = level_number
	change_state(State.PLAYING)
	level_started.emit(level_number)

## Complete the current level and unlock next level
func complete_level() -> void:
	change_state(State.WIN)
	level_completed.emit(current_level)
	
	# Unlock next level if not on final level
	if current_level < MAX_LEVELS and current_level >= max_unlocked_level:
		max_unlocked_level = current_level + 1

## Fail the current level
func fail_level() -> void:
	change_state(State.LOSS)

## Pause the game (only from PLAYING state)
func pause_game() -> void:
	if current_state != State.PLAYING:
		push_warning("Cannot pause from state: " + str(current_state))
		return
	
	change_state(State.PAUSED)

## Resume the game (only from PAUSED state)
func resume_game() -> void:
	if current_state != State.PAUSED:
		push_warning("Cannot resume from state: " + str(current_state))
		return
	
	change_state(State.PLAYING)

## Return to the main menu
func return_to_menu() -> void:
	change_state(State.MENU)
