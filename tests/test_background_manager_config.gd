extends Node

## Test Background_Manager configuration loading and error handling
## Tests Task 2.1 requirements

var background_manager = null

func run_tests():
	print("\n=== Running Background_Manager Configuration Tests ===\n")
	
	# Create a local instance for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	background_manager = BackgroundManagerScript.new()
	background_manager._ready()
	
	test_config_loads_successfully()
	test_config_has_required_structure()
	test_fallback_colors_defined()
	test_level_backgrounds_configured()
	test_menu_background_configured()
	test_get_background_path()
	test_fallback_config_structure()
	
	# Cleanup
	background_manager.queue_free()
	
	print("\n✓ All Background_Manager configuration tests passed!\n")

func test_config_loads_successfully():
	print("--- Test 1: Config loads successfully ---")
	# Verify config was loaded
	assert(background_manager.is_initialized, "BackgroundManager should be initialized")
	assert(not background_manager.config_data.is_empty(), "Config data should not be empty")
	print("  ✓ PASS: Configuration loaded successfully")

func test_config_has_required_structure():
	print("--- Test 2: Config has required structure ---")
	# Verify defaults section exists
	assert(background_manager.config_data.has("defaults"), "Config should have defaults section")
	assert(background_manager.config_data["defaults"].has("opacity"), "Defaults should have opacity")
	assert(background_manager.config_data["defaults"].has("fallback_colors"), "Defaults should have fallback_colors")
	
	# Verify backgrounds section exists
	assert(background_manager.config_data.has("backgrounds"), "Config should have backgrounds section")
	print("  ✓ PASS: Config has required structure")

func test_fallback_colors_defined():
	print("--- Test 3: Fallback colors defined ---")
	# Verify all three level fallback colors are defined
	var fallback_colors = background_manager.config_data["defaults"]["fallback_colors"]
	
	assert(fallback_colors.has("level_1"), "Should have level_1 fallback color")
	assert(fallback_colors["level_1"] == "#8B4513", "Level 1 should be warm brown")
	
	assert(fallback_colors.has("level_2"), "Should have level_2 fallback color")
	assert(fallback_colors["level_2"] == "#4682B4", "Level 2 should be steel blue")
	
	assert(fallback_colors.has("level_3"), "Should have level_3 fallback color")
	assert(fallback_colors["level_3"] == "#9370DB", "Level 3 should be medium purple")
	print("  ✓ PASS: All fallback colors defined correctly")

func test_level_backgrounds_configured():
	print("--- Test 4: Level backgrounds configured ---")
	# Verify all three level backgrounds are configured
	var backgrounds = background_manager.config_data["backgrounds"]
	
	assert(backgrounds.has("level_1"), "Should have level_1 background config")
	assert(backgrounds["level_1"]["type"] == "static", "Level 1 should be static")
	
	assert(backgrounds.has("level_2"), "Should have level_2 background config")
	assert(backgrounds["level_2"]["type"] == "static", "Level 2 should be static")
	
	assert(backgrounds.has("level_3"), "Should have level_3 background config")
	assert(backgrounds["level_3"]["type"] == "static", "Level 3 should be static")
	print("  ✓ PASS: All level backgrounds configured")

func test_menu_background_configured():
	print("--- Test 5: Menu background configured ---")
	# Verify menu background is configured
	var backgrounds = background_manager.config_data["backgrounds"]
	
	assert(backgrounds.has("menu"), "Should have menu background config")
	assert(backgrounds["menu"]["type"] == "animated", "Menu should be animated")
	assert(backgrounds["menu"].has("animation_speed"), "Menu should have animation_speed")
	assert(backgrounds["menu"].has("loop"), "Menu should have loop setting")
	assert(backgrounds["menu"].has("frame_count"), "Menu should have frame_count")
	print("  ✓ PASS: Menu background configured correctly")

func test_get_background_path():
	print("--- Test 6: Get background path ---")
	# Test getting background paths from config
	var level_1_path = background_manager.get_background_path("level_1")
	assert(level_1_path == "res://assets/backgrounds/level_1_bg.png", "Should return correct level 1 path")
	
	var menu_path = background_manager.get_background_path("menu")
	assert(menu_path == "res://assets/backgrounds/menu_bg", "Should return correct menu path")
	
	var invalid_path = background_manager.get_background_path("nonexistent")
	assert(invalid_path == "", "Should return empty string for nonexistent background")
	print("  ✓ PASS: get_background_path() works correctly")

func test_fallback_config_structure():
	print("--- Test 7: Fallback config structure ---")
	# Verify the hardcoded fallback config has the same structure
	var original_config = background_manager.config_data.duplicate(true)
	
	# Simulate fallback by calling _use_fallback_config
	background_manager._use_fallback_config()
	
	# Verify fallback has required structure
	assert(background_manager.config_data.has("defaults"), "Fallback should have defaults")
	assert(background_manager.config_data.has("backgrounds"), "Fallback should have backgrounds")
	assert(background_manager.config_data["defaults"].has("fallback_colors"), "Fallback should have fallback_colors")
	
	# Restore original config
	background_manager.config_data = original_config
	print("  ✓ PASS: Fallback config has correct structure")
