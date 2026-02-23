extends Node

## Test suite for Task 4.3: Background transition logic
## Validates that transitions work correctly between menu and levels

var bg_manager = null
var mock_game_state = null

func run_tests():
	print("\n=== Running Background Transition Tests ===\n")
	
	# Create instances for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	bg_manager = BackgroundManagerScript.new()
	
	# Create a mock GameState for testing
	mock_game_state = Node.new()
	mock_game_state.name = "GameState"
	mock_game_state.set_script(load("res://scripts/game_state.gd"))
	
	# Add to tree so signals work
	add_child(bg_manager)
	add_child(mock_game_state)
	
	# Initialize background manager
	bg_manager._ready()
	
	test_signal_handlers_exist()
	test_connection_method_exists()
	test_menu_background_on_menu_state()
	test_level_background_on_level_started()
	test_cleanup_before_transition()
	
	# Cleanup
	bg_manager.queue_free()
	mock_game_state.queue_free()
	
	print("\n✓ All Background Transition tests passed!\n")

func cleanup():
	if bg_manager:
		bg_manager.cleanup_current_background()

func test_signal_handlers_exist():
	print("--- Test 1: Signal handler methods exist ---")
	
	# Check that signal handlers exist
	assert(bg_manager.has_method("_on_game_state_changed"),
		"BackgroundManager should have _on_game_state_changed method")
	assert(bg_manager.has_method("_on_level_started"),
		"BackgroundManager should have _on_level_started method")
	
	print("  ✓ PASS: Signal handler methods exist")

func test_connection_method_exists():
	print("--- Test 2: Connection method exists ---")
	
	assert(bg_manager.has_method("_connect_to_game_state"),
		"BackgroundManager should have _connect_to_game_state method")
	
	print("  ✓ PASS: _connect_to_game_state method exists")

func test_menu_background_on_menu_state():
	print("--- Test 3: Menu background loads on MENU state ---")
	
	cleanup()
	
	# Call the state change handler with MENU state (0)
	bg_manager._on_game_state_changed(0)
	
	# Verify menu background loaded
	assert(bg_manager.current_background_id == "menu",
		"Should have menu background after MENU state, got: " + bg_manager.current_background_id)
	
	print("  ✓ PASS: Menu background loads on MENU state")

func test_level_background_on_level_started():
	print("--- Test 4: Level backgrounds load on level_started signal ---")
	
	# Test level 1
	cleanup()
	bg_manager._on_level_started(1)
	assert(bg_manager.current_background_id == "level_1",
		"Should have level_1 background, got: " + bg_manager.current_background_id)
	print("  ✓ Level 1 background loaded")
	
	# Test level 2
	cleanup()
	bg_manager._on_level_started(2)
	assert(bg_manager.current_background_id == "level_2",
		"Should have level_2 background, got: " + bg_manager.current_background_id)
	print("  ✓ Level 2 background loaded")
	
	# Test level 3
	cleanup()
	bg_manager._on_level_started(3)
	assert(bg_manager.current_background_id == "level_3",
		"Should have level_3 background, got: " + bg_manager.current_background_id)
	print("  ✓ Level 3 background loaded")
	
	print("  ✓ PASS: All level backgrounds load correctly")

func test_cleanup_before_transition():
	print("--- Test 5: Cleanup happens before transition ---")
	
	# Load level 1
	cleanup()
	bg_manager._on_level_started(1)
	var first_canvas_layer = bg_manager.current_canvas_layer
	assert(first_canvas_layer != null, "First background should be loaded")
	
	# Transition to level 2 (cleanup is called inside _load_background)
	bg_manager._on_level_started(2)
	var second_canvas_layer = bg_manager.current_canvas_layer
	
	# The canvas layers should be different objects
	assert(first_canvas_layer != second_canvas_layer,
		"Canvas layer should be different after transition")
	
	# Verify only level 2 background exists
	assert(bg_manager.current_background_id == "level_2",
		"Should only have level_2 background")
	
	print("  ✓ PASS: Cleanup happens before transition")
	cleanup()
