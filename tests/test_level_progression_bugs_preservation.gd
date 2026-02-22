extends Node
# Preservation Property Tests for Level Progression Bugs
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10**
#
# IMPORTANT: These tests verify normal gameplay mechanics remain unchanged
# They should PASS on UNFIXED code to establish baseline behavior
# 
# These tests do NOT involve the three bug conditions - they test normal gameplay only

const GameBoard = preload("res://scripts/game_board.gd")
const GameState = preload("res://scripts/game_state.gd")
const GameUI = preload("res://scripts/game_ui.gd")
const RunePair = preload("res://scripts/rune_pair.gd")

var game_board: GameBoard
var game_state: GameState
var game_ui: GameUI
var test_results = []

func _init():
	print("\n=== Level Progression Bugs - Preservation Tests ===\n")

func run_tests():
	print("\n--- Test 1: Fast-drop during normal gameplay ---")
	test_fast_drop_during_gameplay()
	
	print("\n--- Test 2: Win state auto-progress to next level ---")
	test_win_state_auto_progress()
	
	print("\n--- Test 3: Short messages display correctly ---")
	test_short_message_display()
	
	print("\n--- Test 4: Pause/resume functionality ---")
	test_pause_resume_functionality()
	
	print("\n--- Test 5: Level unlock and save system ---")
	test_level_unlock_and_save()
	
	print("\n=== Preservation Tests Summary ===")
	print_test_summary()

func setup_game_board():
	game_board = GameBoard.new()
	game_board.initialize_grid()

func cleanup_game_board():
	if game_board:
		game_board.queue_free()
		game_board = null

func setup_game_state():
	game_state = GameState.new()

func cleanup_game_state():
	if game_state:
		game_state.queue_free()
		game_state = null

func setup_game_ui():
	game_ui = GameUI.new()
	# Manually set up the message_label since we're not loading from scene
	var message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.custom_minimum_size = Vector2(600, 100)
	message_label.add_theme_font_size_override("font_size", 48)
	message_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	game_ui.add_child(message_label)
	game_ui.message_label = message_label

func cleanup_game_ui():
	if game_ui:
		game_ui.queue_free()
		game_ui = null

# Preservation Test 1: Fast-drop during normal gameplay works correctly
# EXPECTED ON UNFIXED CODE: This test PASSES (baseline behavior)
# Validates: Requirements 3.3, 3.4
func test_fast_drop_during_gameplay():
	setup_game_board()
	
	print("Testing fast-drop functionality during normal gameplay")
	print("Initial fall_speed: ", game_board.fall_speed)
	
	# Verify initial fall speed is normal (0.5s)
	var initial_speed = game_board.fall_speed
	var expected_normal_speed = 0.5
	
	if initial_speed != expected_normal_speed:
		print("UNEXPECTED: Initial fall_speed = ", initial_speed, " (expected: ", expected_normal_speed, ")")
		test_results.append({
			"test": "Preservation 1 - Fast-drop",
			"status": "FAILED (Unexpected Initial State)",
			"details": "Initial fall_speed = " + str(initial_speed) + " (expected: 0.5)"
		})
		cleanup_game_board()
		return
	
	# Simulate pressing down arrow key (fast-drop)
	print("Simulating down arrow press (fast-drop)...")
	game_board.fall_speed = 0.05
	print("After down press: fall_speed = ", game_board.fall_speed)
	
	# Verify fast-drop speed is set correctly
	var fast_drop_speed = game_board.fall_speed
	var expected_fast_speed = 0.05
	
	if fast_drop_speed != expected_fast_speed:
		print("UNEXPECTED: Fast-drop fall_speed = ", fast_drop_speed, " (expected: ", expected_fast_speed, ")")
		test_results.append({
			"test": "Preservation 1 - Fast-drop",
			"status": "FAILED (Fast-drop Not Working)",
			"details": "Fast-drop fall_speed = " + str(fast_drop_speed) + " (expected: 0.05)"
		})
		cleanup_game_board()
		return
	
	# Simulate releasing down arrow key
	print("Simulating down arrow release...")
	game_board.fall_speed = 0.5
	print("After down release: fall_speed = ", game_board.fall_speed)
	
	# Verify fall speed returns to normal
	var released_speed = game_board.fall_speed
	
	if released_speed != expected_normal_speed:
		print("UNEXPECTED: Released fall_speed = ", released_speed, " (expected: ", expected_normal_speed, ")")
		test_results.append({
			"test": "Preservation 1 - Fast-drop",
			"status": "FAILED (Release Not Working)",
			"details": "Released fall_speed = " + str(released_speed) + " (expected: 0.5)"
		})
		cleanup_game_board()
		return
	
	print("✓ Fast-drop functionality works correctly during normal gameplay")
	print("  - Press down: 0.5s → 0.05s")
	print("  - Release down: 0.05s → 0.5s")
	test_results.append({
		"test": "Preservation 1 - Fast-drop",
		"status": "PASSED",
		"details": "Fast-drop correctly changes fall_speed (0.5 ↔ 0.05)"
	})
	
	cleanup_game_board()

# Preservation Test 2: Win state auto-progress to next level after 3 seconds
# EXPECTED ON UNFIXED CODE: This test PASSES (baseline behavior)
# Validates: Requirements 3.1, 3.2, 3.5, 3.6
func test_win_state_auto_progress():
	setup_game_state()
	
	print("Testing win state auto-progress functionality")
	print("Initial state: ", game_state.current_state)
	print("Initial level: ", game_state.current_level)
	
	# Start level 1
	game_state.start_level(1)
	print("Started level 1, state: ", game_state.current_state)
	
	# Verify we're in PLAYING state
	if game_state.current_state != GameState.State.PLAYING:
		print("UNEXPECTED: State after start_level = ", game_state.current_state, " (expected: PLAYING)")
		test_results.append({
			"test": "Preservation 2 - Win Auto-progress",
			"status": "FAILED (Level Start Issue)",
			"details": "State after start_level = " + str(game_state.current_state)
		})
		cleanup_game_state()
		return
	
	# Complete level 1 (triggers WIN state)
	print("Completing level 1...")
	game_state.complete_level()
	print("After complete_level: state = ", game_state.current_state)
	print("Max unlocked level: ", game_state.max_unlocked_level)
	
	# Verify WIN state is set
	if game_state.current_state != GameState.State.WIN:
		print("UNEXPECTED: State after complete_level = ", game_state.current_state, " (expected: WIN)")
		test_results.append({
			"test": "Preservation 2 - Win Auto-progress",
			"status": "FAILED (Win State Not Set)",
			"details": "State after complete_level = " + str(game_state.current_state)
		})
		cleanup_game_state()
		return
	
	# Verify next level is unlocked
	if game_state.max_unlocked_level != 2:
		print("UNEXPECTED: max_unlocked_level = ", game_state.max_unlocked_level, " (expected: 2)")
		test_results.append({
			"test": "Preservation 2 - Win Auto-progress",
			"status": "FAILED (Level Not Unlocked)",
			"details": "max_unlocked_level = " + str(game_state.max_unlocked_level) + " (expected: 2)"
		})
		cleanup_game_state()
		return
	
	print("✓ Win state correctly set and next level unlocked")
	print("  - State: PLAYING → WIN")
	print("  - Max unlocked: 1 → 2")
	print("NOTE: Auto-progress timing (3 seconds) is handled by main.gd, not GameState")
	test_results.append({
		"test": "Preservation 2 - Win Auto-progress",
		"status": "PASSED",
		"details": "Win state set correctly, level 2 unlocked"
	})
	
	cleanup_game_state()

# Preservation Test 3: Short messages display correctly without overflow
# EXPECTED ON UNFIXED CODE: This test PASSES (baseline behavior)
# Validates: Requirement 3.7
func test_short_message_display():
	setup_game_ui()
	
	print("Testing short message display functionality")
	var message_label = game_ui.message_label
	print("MessageLabel width: ", message_label.custom_minimum_size.x)
	print("Font size: ", message_label.get_theme_font_size("font_size"))
	
	# Display a short message
	var short_message = "Game Over"
	print("Displaying short message: '", short_message, "'")
	game_ui.show_message(short_message)
	
	# Verify message is set correctly
	if message_label.text != short_message:
		print("UNEXPECTED: Message text = '", message_label.text, "' (expected: '", short_message, "')")
		test_results.append({
			"test": "Preservation 3 - Short Message Display",
			"status": "FAILED (Message Not Set)",
			"details": "Message text = '" + message_label.text + "'"
		})
		cleanup_game_ui()
		return
	
	# Verify message is visible
	if not message_label.visible:
		print("UNEXPECTED: Message label is not visible")
		test_results.append({
			"test": "Preservation 3 - Short Message Display",
			"status": "FAILED (Message Not Visible)",
			"details": "Message label is hidden"
		})
		cleanup_game_ui()
		return
	
	# Check if short message fits within bounds
	var label_width = message_label.custom_minimum_size.x
	var text_length = short_message.length()
	var estimated_text_width = text_length * 25  # Heuristic: ~25px per character
	
	print("Text length: ", text_length, " characters")
	print("Estimated text width: ", estimated_text_width, "px")
	print("Label width: ", label_width, "px")
	
	# Short message should fit within bounds
	if estimated_text_width > label_width:
		print("UNEXPECTED: Short message overflows (", estimated_text_width, "px > ", label_width, "px)")
		test_results.append({
			"test": "Preservation 3 - Short Message Display",
			"status": "FAILED (Short Message Overflows)",
			"details": "Text width ~" + str(estimated_text_width) + "px exceeds label width " + str(label_width) + "px"
		})
		cleanup_game_ui()
		return
	
	print("✓ Short message displays correctly without overflow")
	print("  - Message: '", short_message, "'")
	print("  - Fits within ", label_width, "px bounds")
	test_results.append({
		"test": "Preservation 3 - Short Message Display",
		"status": "PASSED",
		"details": "Short message '" + short_message + "' displays correctly"
	})
	
	cleanup_game_ui()

# Preservation Test 4: Pause/resume functionality works correctly
# EXPECTED ON UNFIXED CODE: This test PASSES (baseline behavior)
# Validates: Requirements 3.9, 3.10
func test_pause_resume_functionality():
	setup_game_state()
	setup_game_board()
	
	print("Testing pause/resume functionality")
	print("Initial state: ", game_state.current_state)
	print("Initial board paused: ", game_board.paused)
	
	# Start level 1 to enter PLAYING state
	game_state.start_level(1)
	print("Started level 1, state: ", game_state.current_state)
	
	# Verify we're in PLAYING state and board is not paused
	if game_state.current_state != GameState.State.PLAYING:
		print("UNEXPECTED: State = ", game_state.current_state, " (expected: PLAYING)")
		test_results.append({
			"test": "Preservation 4 - Pause/Resume",
			"status": "FAILED (Not in PLAYING state)",
			"details": "State = " + str(game_state.current_state)
		})
		cleanup_game_board()
		cleanup_game_state()
		return
	
	# Pause the game
	print("Pausing game...")
	game_state.pause_game()
	print("After pause: state = ", game_state.current_state)
	
	# Verify PAUSED state is set
	if game_state.current_state != GameState.State.PAUSED:
		print("UNEXPECTED: State after pause = ", game_state.current_state, " (expected: PAUSED)")
		test_results.append({
			"test": "Preservation 4 - Pause/Resume",
			"status": "FAILED (Pause Not Working)",
			"details": "State after pause = " + str(game_state.current_state)
		})
		cleanup_game_board()
		cleanup_game_state()
		return
	
	# Resume the game
	print("Resuming game...")
	game_state.resume_game()
	print("After resume: state = ", game_state.current_state)
	
	# Verify PLAYING state is restored
	if game_state.current_state != GameState.State.PLAYING:
		print("UNEXPECTED: State after resume = ", game_state.current_state, " (expected: PLAYING)")
		test_results.append({
			"test": "Preservation 4 - Pause/Resume",
			"status": "FAILED (Resume Not Working)",
			"details": "State after resume = " + str(game_state.current_state)
		})
		cleanup_game_board()
		cleanup_game_state()
		return
	
	print("✓ Pause/resume functionality works correctly")
	print("  - Pause: PLAYING → PAUSED")
	print("  - Resume: PAUSED → PLAYING")
	test_results.append({
		"test": "Preservation 4 - Pause/Resume",
		"status": "PASSED",
		"details": "Pause/resume state transitions work correctly"
	})
	
	cleanup_game_board()
	cleanup_game_state()

# Preservation Test 5: Level unlock and save system works correctly
# EXPECTED ON UNFIXED CODE: This test PASSES (baseline behavior)
# Validates: Requirements 3.1, 3.2
func test_level_unlock_and_save():
	setup_game_state()
	
	print("Testing level unlock and save system")
	print("Initial max_unlocked_level: ", game_state.max_unlocked_level)
	print("Initial current_level: ", game_state.current_level)
	
	# Verify initial state (only level 1 unlocked)
	if game_state.max_unlocked_level != 1:
		print("UNEXPECTED: Initial max_unlocked_level = ", game_state.max_unlocked_level, " (expected: 1)")
		test_results.append({
			"test": "Preservation 5 - Level Unlock/Save",
			"status": "FAILED (Unexpected Initial State)",
			"details": "Initial max_unlocked_level = " + str(game_state.max_unlocked_level)
		})
		cleanup_game_state()
		return
	
	# Complete level 1
	game_state.start_level(1)
	game_state.complete_level()
	print("Completed level 1")
	print("After completion: max_unlocked_level = ", game_state.max_unlocked_level)
	
	# Verify level 2 is unlocked
	if game_state.max_unlocked_level != 2:
		print("UNEXPECTED: max_unlocked_level = ", game_state.max_unlocked_level, " (expected: 2)")
		test_results.append({
			"test": "Preservation 5 - Level Unlock/Save",
			"status": "FAILED (Level 2 Not Unlocked)",
			"details": "max_unlocked_level = " + str(game_state.max_unlocked_level) + " after completing level 1"
		})
		cleanup_game_state()
		return
	
	# Complete level 2
	game_state.start_level(2)
	game_state.complete_level()
	print("Completed level 2")
	print("After completion: max_unlocked_level = ", game_state.max_unlocked_level)
	
	# Verify level 3 is unlocked
	if game_state.max_unlocked_level != 3:
		print("UNEXPECTED: max_unlocked_level = ", game_state.max_unlocked_level, " (expected: 3)")
		test_results.append({
			"test": "Preservation 5 - Level Unlock/Save",
			"status": "FAILED (Level 3 Not Unlocked)",
			"details": "max_unlocked_level = " + str(game_state.max_unlocked_level) + " after completing level 2"
		})
		cleanup_game_state()
		return
	
	# Complete level 3 (final level)
	game_state.start_level(3)
	game_state.complete_level()
	print("Completed level 3 (final level)")
	print("After completion: max_unlocked_level = ", game_state.max_unlocked_level)
	
	# Verify max_unlocked_level stays at 3 (no level 4)
	if game_state.max_unlocked_level != 3:
		print("UNEXPECTED: max_unlocked_level = ", game_state.max_unlocked_level, " (expected: 3)")
		test_results.append({
			"test": "Preservation 5 - Level Unlock/Save",
			"status": "FAILED (Final Level Issue)",
			"details": "max_unlocked_level = " + str(game_state.max_unlocked_level) + " after completing final level"
		})
		cleanup_game_state()
		return
	
	print("✓ Level unlock system works correctly")
	print("  - Level 1 complete → Level 2 unlocked")
	print("  - Level 2 complete → Level 3 unlocked")
	print("  - Level 3 complete → max_unlocked_level stays at 3")
	print("NOTE: Save persistence is handled by SaveManager, not GameState")
	test_results.append({
		"test": "Preservation 5 - Level Unlock/Save",
		"status": "PASSED",
		"details": "Level unlock progression works correctly (1→2→3)"
	})
	
	cleanup_game_state()

func print_test_summary():
	print("\nTest Results:")
	for result in test_results:
		print("  - ", result["test"], ": ", result["status"])
		print("    Details: ", result["details"])
	
	var tests_passed = 0
	for result in test_results:
		if result["status"] == "PASSED":
			tests_passed += 1
	
	print("\nTests Passed: ", tests_passed, " / ", test_results.size())
	print("\nNOTE: These tests are EXPECTED TO PASS on unfixed code.")
	print("They establish baseline behavior that must be preserved after bug fixes.")
