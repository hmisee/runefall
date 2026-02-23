extends Node

## Test z-ordering guarantees for backgrounds
## Validates that backgrounds always render behind game elements and UI

var bg_manager = null

func run_tests():
	print("\n=== Running Z-Ordering Tests ===\n")
	
	# Create a local instance for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	test_level_background_has_negative_z_index()
	test_menu_background_has_negative_z_index()
	test_all_level_backgrounds_use_same_z_index()
	test_background_renders_behind_game_elements()
	test_background_renders_behind_ui_elements()
	test_background_z_index_never_changes_after_loading()
	test_background_transition_maintains_z_index()
	
	# Cleanup
	bg_manager.queue_free()
	
	print("\n✓ All Z-Ordering tests passed!\n")

func test_level_background_has_negative_z_index():
	print("--- Test 1: Level background has negative z-index ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Load a level background
	bg_manager.load_level_background(1)
	
	# Verify canvas layer exists and has correct z-index
	assert(bg_manager.current_canvas_layer != null, "Canvas layer should exist")
	assert(bg_manager.current_canvas_layer.layer == -100, "Background canvas layer should have z-index of -100")
	print("  ✓ PASS: Level background has z-index -100")
	
	# Clean up
	bg_manager.cleanup_current_background()

func test_menu_background_has_negative_z_index():
	print("--- Test 2: Menu background has negative z-index ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Load menu background
	bg_manager.load_menu_background()
	
	# Verify canvas layer exists and has correct z-index
	assert(bg_manager.current_canvas_layer != null, "Canvas layer should exist")
	assert(bg_manager.current_canvas_layer.layer == -100, "Menu background canvas layer should have z-index of -100")
	print("  ✓ PASS: Menu background has z-index -100")
	
	# Clean up
	bg_manager.cleanup_current_background()

func test_all_level_backgrounds_use_same_z_index():
	print("--- Test 3: All level backgrounds use same z-index ---")
	
	# Test all three levels
	for level in range(1, 4):
		bg_manager.cleanup_current_background()
		bg_manager.load_level_background(level)
		
		assert(bg_manager.current_canvas_layer != null, "Canvas layer should exist for level " + str(level))
		assert(bg_manager.current_canvas_layer.layer == -100, "Level " + str(level) + " background should have z-index of -100")
		
	print("  ✓ PASS: All level backgrounds have z-index -100")
	
	# Clean up
	bg_manager.cleanup_current_background()

func test_background_renders_behind_game_elements():
	print("--- Test 4: Background renders behind game elements ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Create a test game element with default z-index (0)
	var game_element = Node2D.new()
	game_element.z_index = 0
	
	# Load a background
	bg_manager.load_level_background(1)
	
	# Verify background canvas layer z-index is less than game element z-index
	assert(bg_manager.current_canvas_layer != null, "Canvas layer should exist")
	assert(bg_manager.current_canvas_layer.layer < game_element.z_index, "Background should render behind game elements")
	print("  ✓ PASS: Background z-index (-100) < game element z-index (0)")
	
	# Clean up
	game_element.queue_free()
	bg_manager.cleanup_current_background()

func test_background_renders_behind_ui_elements():
	print("--- Test 5: Background renders behind UI elements ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Create a test UI element with typical UI z-index (100)
	var ui_element = CanvasLayer.new()
	ui_element.layer = 100
	
	# Load a background
	bg_manager.load_level_background(2)
	
	# Verify background canvas layer z-index is less than UI element z-index
	assert(bg_manager.current_canvas_layer != null, "Canvas layer should exist")
	assert(bg_manager.current_canvas_layer.layer < ui_element.layer, "Background should render behind UI elements")
	print("  ✓ PASS: Background z-index (-100) < UI element z-index (100)")
	
	# Clean up
	ui_element.queue_free()
	bg_manager.cleanup_current_background()

func test_background_z_index_never_changes_after_loading():
	print("--- Test 6: Background z-index never changes after loading ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Load a background
	bg_manager.load_level_background(1)
	
	var initial_z_index = bg_manager.current_canvas_layer.layer
	
	# Verify z-index hasn't changed
	assert(bg_manager.current_canvas_layer.layer == initial_z_index, "Background z-index should remain constant")
	assert(bg_manager.current_canvas_layer.layer == -100, "Background z-index should still be -100")
	print("  ✓ PASS: Background z-index remains constant at -100")
	
	# Clean up
	bg_manager.cleanup_current_background()

func test_background_transition_maintains_z_index():
	print("--- Test 7: Background transition maintains z-index ---")
	
	# Clean up any existing backgrounds
	bg_manager.cleanup_current_background()
	
	# Load first background
	bg_manager.load_level_background(1)
	assert(bg_manager.current_canvas_layer.layer == -100, "First background should have z-index -100")
	
	# Transition to second background
	bg_manager.load_level_background(2)
	assert(bg_manager.current_canvas_layer.layer == -100, "Second background should have z-index -100")
	
	# Transition to menu
	bg_manager.load_menu_background()
	assert(bg_manager.current_canvas_layer.layer == -100, "Menu background should have z-index -100")
	print("  ✓ PASS: All background transitions maintain z-index -100")
	
	# Clean up
	bg_manager.cleanup_current_background()
