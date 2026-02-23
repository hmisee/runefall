extends Node

## Test Background_Manager setup and configuration loading

var test_passed = true

func _ready():
	print("=== Background Manager Setup Tests ===")
	print("\nVerifying Background_Manager autoload, configuration, and asset structure.\n")
	
	run_all_tests()
	
	if test_passed:
		print("\n✓ All Background Manager setup tests passed!")
		print("✓ Configuration loaded successfully")
		print("✓ All background assets exist")
		print("✓ Fallback colors configured")
		get_tree().quit(0)
	else:
		print("\n✗ Some tests failed")
		get_tree().quit(1)

func run_all_tests():
	test_background_manager_autoload_exists()
	test_background_manager_initialized()
	test_config_loaded()
	test_config_has_defaults()
	test_config_has_backgrounds()
	test_config_has_all_level_backgrounds()
	test_config_has_menu_background()
	test_level_backgrounds_are_static()
	test_menu_background_is_animated()
	test_background_paths_exist()
	test_menu_animation_frames_exist()
	test_get_background_path()
	test_has_background_asset()
	test_fallback_colors_defined()

func assert_true(condition: bool, message: String):
	if not condition:
		print("✗ FAILED: ", message)
		test_passed = false
	else:
		print("✓ ", message)

func assert_false(condition: bool, message: String):
	assert_true(not condition, message)

func assert_not_null(value, message: String):
	assert_true(value != null, message)

func assert_eq(actual, expected, message: String):
	if actual != expected:
		print("✗ FAILED: ", message)
		print("  Expected: ", expected)
		print("  Actual: ", actual)
		test_passed = false
	else:
		print("✓ ", message)

func test_background_manager_autoload_exists():
	assert_not_null(BackgroundManager, "BackgroundManager should be autoloaded")

func test_background_manager_initialized():
	assert_true(BackgroundManager.is_initialized, "BackgroundManager should be initialized")

func test_config_loaded():
	assert_false(BackgroundManager.config_data.is_empty(), "Configuration should be loaded")

func test_config_has_defaults():
	assert_true(BackgroundManager.config_data.has("defaults"), "Config should have defaults section")
	assert_true(BackgroundManager.config_data["defaults"].has("fallback_colors"), "Defaults should have fallback_colors")

func test_config_has_backgrounds():
	assert_true(BackgroundManager.config_data.has("backgrounds"), "Config should have backgrounds section")

func test_config_has_all_level_backgrounds():
	var backgrounds = BackgroundManager.config_data["backgrounds"]
	assert_true(backgrounds.has("level_1"), "Config should have level_1 background")
	assert_true(backgrounds.has("level_2"), "Config should have level_2 background")
	assert_true(backgrounds.has("level_3"), "Config should have level_3 background")

func test_config_has_menu_background():
	var backgrounds = BackgroundManager.config_data["backgrounds"]
	assert_true(backgrounds.has("menu"), "Config should have menu background")

func test_level_backgrounds_are_static():
	var backgrounds = BackgroundManager.config_data["backgrounds"]
	assert_eq(backgrounds["level_1"]["type"], "static", "Level 1 should be static")
	assert_eq(backgrounds["level_2"]["type"], "static", "Level 2 should be static")
	assert_eq(backgrounds["level_3"]["type"], "static", "Level 3 should be static")

func test_menu_background_is_animated():
	var backgrounds = BackgroundManager.config_data["backgrounds"]
	assert_eq(backgrounds["menu"]["type"], "animated", "Menu should be animated")

func test_background_paths_exist():
	assert_true(FileAccess.file_exists("res://assets/backgrounds/level_1_bg.png"), "Level 1 background file should exist")
	assert_true(FileAccess.file_exists("res://assets/backgrounds/level_2_bg.png"), "Level 2 background file should exist")
	assert_true(FileAccess.file_exists("res://assets/backgrounds/level_3_bg.png"), "Level 3 background file should exist")

func test_menu_animation_frames_exist():
	for i in range(8):
		var frame_path = "res://assets/backgrounds/menu_bg/frame_" + str(i) + ".png"
		assert_true(FileAccess.file_exists(frame_path), "Menu frame " + str(i) + " should exist")

func test_get_background_path():
	var level_1_path = BackgroundManager.get_background_path("level_1")
	assert_eq(level_1_path, "res://assets/backgrounds/level_1_bg.png", "Should return correct path for level_1")

func test_has_background_asset():
	assert_true(BackgroundManager.has_background_asset("level_1"), "Should detect level_1 asset exists")
	assert_true(BackgroundManager.has_background_asset("level_2"), "Should detect level_2 asset exists")
	assert_true(BackgroundManager.has_background_asset("level_3"), "Should detect level_3 asset exists")

func test_fallback_colors_defined():
	var fallback_colors = BackgroundManager.config_data["defaults"]["fallback_colors"]
	assert_true(fallback_colors.has("level_1"), "Should have level_1 fallback color")
	assert_true(fallback_colors.has("level_2"), "Should have level_2 fallback color")
	assert_true(fallback_colors.has("level_3"), "Should have level_3 fallback color")
	
	# Verify colors are valid hex strings
	assert_eq(fallback_colors["level_1"], "#8B4513", "Level 1 fallback should be warm brown")
	assert_eq(fallback_colors["level_2"], "#4682B4", "Level 2 fallback should be steel blue")
	assert_eq(fallback_colors["level_3"], "#9370DB", "Level 3 fallback should be medium purple")
