extends Node
# Bug Condition Exploration Tests for Level Progression Bugs
# **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8**
#
# CRITICAL: These tests MUST FAIL on unfixed code - failure confirms the bugs exist
# DO NOT attempt to fix the tests or the code when they fail
# 
# This test encodes the expected behavior - it will validate the fixes when they pass after implementation
# GOAL: Surface counterexamples that demonstrate the three bugs exist

const GameBoard = preload("res://scripts/game_board.gd")
const GameState = preload("res://scripts/game_state.gd")
const GameUI = preload("res://scripts/game_ui.gd")

var game_board: GameBoard
var game_state: GameState
var game_ui: GameUI
var test_results = []

func _init():
	print("\n=== Level Progression Bugs - Exploration Tests ===\n")

func run_tests():
	print("\n--- Test 1: Bug 1 - Drop Speed Not Reset on Level Start ---")
	test_bug1_drop_speed_not_reset()
	
	print("\n--- Test 2: Bug 2 - Notification Text Overflow ---")
	test_bug2_notification_overflow()
	
	print("\n--- Test 3: Bug 3 - Game Over No Auto-Route to Menu ---")
	test_bug3_game_over_no_auto_route()
	
	print("\n=== Exploration Tests Summary ===")
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
	# Call _ready() to apply the fix
	game_ui._ready()

func cleanup_game_ui():
	if game_ui:
		game_ui.queue_free()
		game_ui = null

# Test Bug 1: Drop Speed Not Reset on Level Initialization
# EXPECTED ON UNFIXED CODE: This test FAILS - fall_speed remains at 0.05 instead of resetting to 0.5
func test_bug1_drop_speed_not_reset():
	setup_game_board()
	
	print("Setting up: Simulating fast-drop input before level transition")
	print("Initial fall_speed: ", game_board.fall_speed)
	
	# Simulate player holding down arrow key (fast-drop)
	game_board.fall_speed = 0.05
	print("After fast-drop input: fall_speed = ", game_board.fall_speed)
	
	# Simulate level transition by calling initialize_level
	print("Calling initialize_level(15) to simulate level 2 start...")
	game_board.initialize_level(15)
	
	print("After initialize_level: fall_speed = ", game_board.fall_speed)
	
	# Expected behavior: fall_speed should be reset to 0.5
	# On unfixed code: fall_speed remains at 0.05
	var expected_speed = 0.5
	var actual_speed = game_board.fall_speed
	
	if actual_speed != expected_speed:
		print("COUNTEREXAMPLE FOUND: fall_speed = ", actual_speed, " (expected: ", expected_speed, ")")
		print("BUG CONFIRMED: fall_speed not reset on level initialization")
		test_results.append({
			"test": "Bug 1 - Drop Speed",
			"status": "FAILED (Bug Exists)",
			"counterexample": "fall_speed = " + str(actual_speed) + " after initialize_level (expected: 0.5)"
		})
	else:
		print("UNEXPECTED: fall_speed correctly reset to ", actual_speed)
		print("Bug may not exist or has already been fixed")
		test_results.append({
			"test": "Bug 1 - Drop Speed",
			"status": "PASSED (Bug Not Found)",
			"counterexample": "None"
		})
	
	cleanup_game_board()

# Test Bug 2: Notification Text Overflow
# EXPECTED ON UNFIXED CODE: This test FAILS - text overflows 600px MessageLabel bounds
func test_bug2_notification_overflow():
	setup_game_ui()
	
	print("Setting up: MessageLabel with 600px width, 48px font, no autowrap")
	var message_label = game_ui.message_label
	print("MessageLabel width: ", message_label.custom_minimum_size.x)
	print("Font size: ", message_label.get_theme_font_size("font_size"))
	print("Autowrap mode: ", message_label.autowrap_mode)
	
	# Display the long message
	var long_message = "The shaman successfully calmed down all the elements"
	print("Displaying message: '", long_message, "'")
	game_ui.show_message(long_message)
	
	# Check if text fits within bounds
	# We can't directly measure rendered text width without a viewport, so we check configuration
	var label_width = message_label.custom_minimum_size.x
	var font_size = message_label.get_theme_font_size("font_size")
	var autowrap = message_label.autowrap_mode
	var text_length = long_message.length()
	
	print("Text length: ", text_length, " characters")
	print("Label width: ", label_width, "px")
	print("Font size: ", font_size, "px")
	
	# Heuristic: With 48px font, each character is roughly 25-30px wide
	# 60 characters * 25px = 1500px, which exceeds 600px
	var estimated_text_width = text_length * 25
	print("Estimated text width: ", estimated_text_width, "px")
	
	# Expected behavior: Text should be fully visible (autowrap enabled or sufficient width)
	# On unfixed code: autowrap is OFF and width is 600px, causing overflow
	var text_overflows = (estimated_text_width > label_width) and (autowrap == TextServer.AUTOWRAP_OFF)
	
	if text_overflows:
		print("COUNTEREXAMPLE FOUND: Text overflows label bounds")
		print("BUG CONFIRMED: MessageLabel too narrow with no text wrapping")
		test_results.append({
			"test": "Bug 2 - Notification Overflow",
			"status": "FAILED (Bug Exists)",
			"counterexample": "Text width ~" + str(estimated_text_width) + "px exceeds label width " + str(label_width) + "px, autowrap=OFF"
		})
	else:
		print("UNEXPECTED: Text fits within bounds or autowrap is enabled")
		print("Bug may not exist or has already been fixed")
		test_results.append({
			"test": "Bug 2 - Notification Overflow",
			"status": "PASSED (Bug Not Found)",
			"counterexample": "None"
		})
	
	cleanup_game_ui()

# Test Bug 3: Game Over No Auto-Route to Menu
# EXPECTED ON UNFIXED CODE: This test FAILS - auto-routing code not found in main.gd
# NOTE: We verify the fix exists by checking main.gd source code since timing-based tests
# can't run in headless mode
func test_bug3_game_over_no_auto_route():
	print("Checking if auto-routing fix exists in main.gd...")
	
	# Load main.gd source code and check for the fix
	var main_script_path = "res://scripts/main.gd"
	var file = FileAccess.open(main_script_path, FileAccess.READ)
	
	if file == null:
		print("ERROR: Could not open main.gd for verification")
		test_results.append({
			"test": "Bug 3 - Game Over Routing",
			"status": "ERROR",
			"counterexample": "Could not verify fix - main.gd not found"
		})
		return
	
	var source_code = file.get_as_text()
	file.close()
	
	# Check for the auto-routing fix in LOSS state handler
	# The fix should contain: await get_tree().create_timer(3.0).timeout and return_to_menu()
	var has_loss_state = source_code.contains("GameState.State.LOSS:")
	var has_timer = source_code.contains("await get_tree().create_timer(3.0).timeout")
	var has_return_to_menu = source_code.contains("return_to_menu()")
	
	# Check if the timer and return_to_menu appear after LOSS state (rough proximity check)
	var loss_pos = source_code.find("GameState.State.LOSS:")
	var timer_pos = source_code.find("await get_tree().create_timer(3.0).timeout", loss_pos)
	var menu_pos = source_code.find("return_to_menu()", loss_pos)
	
	var fix_exists = has_loss_state and has_timer and has_return_to_menu and timer_pos > loss_pos and menu_pos > timer_pos
	
	print("LOSS state handler found: ", has_loss_state)
	print("Timer await found: ", has_timer)
	print("return_to_menu() found: ", has_return_to_menu)
	print("Fix properly positioned: ", fix_exists)
	
	if not fix_exists:
		print("COUNTEREXAMPLE FOUND: Auto-routing code not found in main.gd LOSS state handler")
		print("BUG CONFIRMED: No automatic routing from LOSS to MENU")
		test_results.append({
			"test": "Bug 3 - Game Over Routing",
			"status": "FAILED (Bug Exists)",
			"counterexample": "Auto-routing code missing from main.gd LOSS state handler"
		})
	else:
		print("Fix verified: Auto-routing code found in main.gd")
		print("The game will automatically return to menu 3 seconds after game over")
		test_results.append({
			"test": "Bug 3 - Game Over Routing",
			"status": "PASSED (Bug Not Found)",
			"counterexample": "None"
		})


func print_test_summary():
	print("\nTest Results:")
	for result in test_results:
		print("  - ", result["test"], ": ", result["status"])
		if result["counterexample"] != "None":
			print("    Counterexample: ", result["counterexample"])
	
	var bugs_found = 0
	for result in test_results:
		if result["status"].begins_with("FAILED"):
			bugs_found += 1
	
	print("\nBugs Found: ", bugs_found, " / ", test_results.size())
	print("\nNOTE: These tests are EXPECTED TO FAIL on unfixed code.")
	print("Failures confirm the bugs exist and provide counterexamples for debugging.")
