extends Node

## Integration test for Task 14.1: Complete background system wiring
## Verifies all components work together correctly

func run_tests():
	print("\n=== Running Complete Background Integration Tests ===\n")
	
	test_autoload_registration()
	test_gamestate_autoload()
	test_background_manager_initialization()
	test_configuration_loaded()
	test_required_backgrounds_configured()
	test_api_methods_exist()
	test_signal_handlers_exist()
	test_basic_loading_flow()
	
	print("\n✓ All Complete Integration tests passed!\n")

func test_autoload_registration():
	print("--- Test 1: Background_Manager autoload registration ---")
	
	# Create a Background_Manager instance to verify the script works
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	assert(bg_manager.is_ready(), "Background_Manager should initialize successfully")
	
	bg_manager.queue_free()
	print("  ✓ PASS: Background_Manager autoload script is valid")

func test_gamestate_autoload():
	print("--- Test 2: GameState autoload registration ---")
	
	# Create a GameState instance to verify the script works
	var GameStateScript = load("res://scripts/game_state.gd")
	var game_state = GameStateScript.new()
	
	assert(game_state != null, "GameState should be loadable")
	assert(game_state.has_signal("state_changed"), "GameState should have state_changed signal")
	assert(game_state.has_signal("level_started"), "GameState should have level_started signal")
	
	game_state.queue_free()
	print("  ✓ PASS: GameState autoload script is valid")

func test_background_manager_initialization():
	print("--- Test 3: Background_Manager initialization ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	assert(bg_manager.is_initialized, "Should be initialized after _ready()")
	assert(not bg_manager.config_data.is_empty(), "Config data should be loaded")
	
	bg_manager.queue_free()
	print("  ✓ PASS: Background_Manager initializes correctly")

func test_configuration_loaded():
	print("--- Test 4: Configuration loaded successfully ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	var available = bg_manager.get_available_backgrounds()
	assert(available.size() > 0, "Should have backgrounds configured")
	
	bg_manager.queue_free()
	print("  ✓ PASS: Configuration loaded (", available.size(), " backgrounds)")

func test_required_backgrounds_configured():
	print("--- Test 5: Required backgrounds configured ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	var available = bg_manager.get_available_backgrounds()
	var required = ["level_1", "level_2", "level_3", "menu"]
	
	for bg_id in required:
		assert(available.has(bg_id), "Should have " + bg_id + " configured")
	
	bg_manager.queue_free()
	print("  ✓ PASS: All required backgrounds (menu, level 1-3) configured")

func test_api_methods_exist():
	print("--- Test 6: Background_Manager API methods ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	
	var required_methods = [
		"load_level_background",
		"load_menu_background",
		"cleanup_current_background",
		"get_current_background_id",
		"is_background_loaded",
		"set_background_opacity"
	]
	
	for method in required_methods:
		assert(bg_manager.has_method(method), "Should have method: " + method)
	
	bg_manager.queue_free()
	print("  ✓ PASS: All required API methods exist")

func test_signal_handlers_exist():
	print("--- Test 7: Signal handler methods exist ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	
	assert(bg_manager.has_method("_on_game_state_changed"), "Should have _on_game_state_changed handler")
	assert(bg_manager.has_method("_on_level_started"), "Should have _on_level_started handler")
	assert(bg_manager.has_method("_connect_to_game_state"), "Should have _connect_to_game_state method")
	
	bg_manager.queue_free()
	print("  ✓ PASS: All signal handlers exist")

func test_basic_loading_flow():
	print("--- Test 8: Basic loading flow ---")
	
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	# Test menu background loading
	bg_manager.load_menu_background()
	assert(bg_manager.get_current_background_id() == "menu", "Should load menu background")
	assert(bg_manager.is_background_loaded(), "Background should be loaded")
	
	# Test level 1 background loading
	bg_manager.load_level_background(1)
	assert(bg_manager.get_current_background_id() == "level_1", "Should load level 1 background")
	assert(bg_manager.is_background_loaded(), "Background should be loaded")
	
	# Test level 2 background loading
	bg_manager.load_level_background(2)
	assert(bg_manager.get_current_background_id() == "level_2", "Should load level 2 background")
	assert(bg_manager.is_background_loaded(), "Background should be loaded")
	
	# Test level 3 background loading
	bg_manager.load_level_background(3)
	assert(bg_manager.get_current_background_id() == "level_3", "Should load level 3 background")
	assert(bg_manager.is_background_loaded(), "Background should be loaded")
	
	# Test cleanup
	bg_manager.cleanup_current_background()
	assert(not bg_manager.is_background_loaded(), "Background should be cleaned up")
	assert(bg_manager.get_current_background_id() == "", "Background ID should be empty")
	
	bg_manager.queue_free()
	print("  ✓ PASS: Complete loading flow works (menu → level 1 → level 2 → level 3 → cleanup)")
