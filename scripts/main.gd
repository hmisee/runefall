extends Node2D

@onready var game_board = $GameBoard
@onready var game_state: GameState = null  # Will be set when GameState node is added
@onready var game_ui = null  # Will be set when GameUI node is added
@onready var main_menu = null  # Will be set when MainMenu node is added
@onready var pause_menu = null  # Will be set when PauseMenu node is added
@onready var save_manager = null  # Will be set when SaveManager node is added

func _ready():
	game_board.game_over.connect(_on_game_over)
	
	# Find all nodes
	game_state = get_node_or_null("GameState")
	game_ui = get_node_or_null("GameUI")
	main_menu = get_node_or_null("MainMenu")
	pause_menu = get_node_or_null("PauseMenu")
	save_manager = get_node_or_null("SaveManager")
	
	# Connect GameBoard → GameState (win/loss signals)
	if game_state:
		game_board.win_condition_met.connect(game_state.complete_level)
		game_board.loss_condition_met.connect(game_state.fail_level)
		game_state.state_changed.connect(_on_state_changed)
	
	# Connect GameState → GameUI (state changes, level info)
	if game_state and game_ui:
		game_state.state_changed.connect(_on_state_changed_for_ui)
		game_state.level_started.connect(_on_level_started)
	
	# Connect GameBoard → GameUI (elements count)
	if game_ui:
		game_board.elements_remaining_changed.connect(game_ui.update_elements_count)
		game_board.preview_updated.connect(game_ui.update_preview)
	
	# Connect MainMenu → GameState (level selection)
	if main_menu and game_state:
		main_menu.level_selected.connect(_on_level_selected)
	
	# Connect MainMenu quit signal
	if main_menu:
		main_menu.quit_requested.connect(_on_quit_requested)
	
	# Connect PauseMenu → GameState (pause/resume)
	if pause_menu and game_state:
		pause_menu.resume_requested.connect(game_state.resume_game)
		pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	
	# Connect GameState → SaveManager (level completion)
	if game_state and save_manager:
		game_state.level_completed.connect(_on_level_completed)
	
	# Game initialization flow
	# 1. Load save data
	if save_manager and game_state:
		var max_unlocked = save_manager.load_progress()
		game_state.max_unlocked_level = max_unlocked
	
	# 2. Initialize main menu with unlock state
	if main_menu and game_state:
		main_menu.initialize(game_state.max_unlocked_level)
	
	# 3. Show main menu as initial state
	if main_menu:
		main_menu.show_menu()
	
	# 4. Hide GameUI initially (only show during gameplay)
	if game_ui:
		game_ui.hide()

func _input(event):
	# Handle Escape key for pause
	if event.is_action_pressed("ui_cancel") and game_state:
		if game_state.current_state == GameState.State.PLAYING:
			game_state.pause_game()
		elif game_state.current_state == GameState.State.PAUSED:
			game_state.resume_game()

func _on_state_changed(new_state: GameState.State):
	# Update GameBoard pause state based on game state
	match new_state:
		GameState.State.PLAYING:
			game_board.set_paused(false)
			if pause_menu:
				pause_menu.hide_pause()
		GameState.State.PAUSED:
			game_board.set_paused(true)
			if pause_menu:
				pause_menu.show_pause()
		GameState.State.MENU:
			game_board.set_paused(true)
			if pause_menu:
				pause_menu.hide_pause()
			if main_menu:
				main_menu.show_menu()
			if game_ui:
				game_ui.hide()
		_:
			# For other states (WIN, LOSS, TRANSITION), also pause the board
			game_board.set_paused(true)
			if pause_menu:
				pause_menu.hide_pause()

func _on_state_changed_for_ui(new_state: GameState.State):
	# Display appropriate messages on win/loss
	if not game_ui:
		return
	
	match new_state:
		GameState.State.WIN:
			# Check if this is the final level
			if game_state.current_level == GameState.MAX_LEVELS:
				game_ui.show_message("Congratulations! You have mastered all elements!")
			else:
				game_ui.show_message("The shaman successfully calmed down all the elements")
				# Auto-progress to next level after 3 seconds
				_auto_progress_to_next_level()
		GameState.State.LOSS:
			game_ui.show_message("Game Over - The elements remain angry")
			# Auto-return to main menu after 3 seconds
			await get_tree().create_timer(3.0).timeout
			if game_state:
				game_state.return_to_menu()

func _on_game_over():
	print("Game Over!")

func _on_level_selected(level_number: int):
	"""Handle level selection from main menu"""
	if game_state:
		game_state.start_level(level_number)
	
	# Hide main menu when level starts
	if main_menu:
		main_menu.hide_menu()

func _on_main_menu_requested():
	"""Handle return to main menu from pause menu"""
	if game_state:
		game_state.return_to_menu()
	
	# Hide pause menu and show main menu
	if pause_menu:
		pause_menu.hide_pause()
	if main_menu:
		main_menu.show_menu()

func _on_level_completed(level_number: int):
	"""Handle level completion - save progress"""
	if save_manager and game_state:
		save_manager.save_progress(game_state.max_unlocked_level)

func _on_level_started(level_number: int):
	"""Handle level start - initialize board and update UI"""
	# Show GameUI when level starts
	if game_ui:
		game_ui.show()
	
	# Get level configuration
	var level_config = game_board.LEVEL_CONFIG.get(level_number, {"elements": 10})
	var element_count = level_config["elements"]
	
	# Initialize GameBoard with level config
	game_board.initialize_level(element_count)
	
	# Update UI with level info
	if game_ui:
		game_ui.update_level_display(level_number)
		# Update preview immediately after level initialization
		await get_tree().process_frame  # Wait one frame for board to be ready
		_update_preview_from_board()

func _update_preview_from_board():
	"""Update the preview UI with the next rune pair data from GameBoard"""
	if game_ui and game_board.next_rune_pair_data.size() > 0:
		var data = game_board.next_rune_pair_data
		game_ui.update_preview(data["rune1_type"], data["rune2_type"], data["rotation"])

func _auto_progress_to_next_level():
	# Transition to TRANSITION state during the wait
	game_state.change_state(GameState.State.TRANSITION)
	
	# Wait 3 seconds
	await get_tree().create_timer(3.0).timeout
	
	# Start the next level
	var next_level = game_state.current_level + 1
	game_state.start_level(next_level)

func _on_quit_requested():
	"""Handle quit request from main menu"""
	get_tree().quit()
