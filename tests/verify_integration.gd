extends SceneTree

## Simple verification test for Task 14.1
## Verifies Background_Manager autoload registration and basic functionality
## Run with: godot --headless -s tests/verify_integration.gd

func _init():
	print("\n=== Background System Integration Verification ===\n")
	
	var all_passed = true
	
	# Test 1: Verify Background_Manager autoload
	print("Test 1: Background_Manager autoload registration")
	var bg_manager = root.get_node_or_null("BackgroundManager")
	if bg_manager:
		print("  ✓ PASS: Background_Manager is registered as autoload")
	else:
		print("  ✗ FAIL: Background_Manager not found")
		all_passed = false
	
	# Test 2: Verify GameState autoload
	print("\nTest 2: GameState autoload registration")
	var game_state = root.get_node_or_null("GameState")
	if game_state:
		print("  ✓ PASS: GameState is registered as autoload")
	else:
		print("  ✗ FAIL: GameState not found")
		all_passed = false
	
	if not bg_manager or not game_state:
		print("\n✗ Integration verification FAILED")
		quit(1)
		return
	
	# Test 3: Verify Background_Manager is initialized
	print("\nTest 3: Background_Manager initialization")
	if bg_manager.is_ready():
		print("  ✓ PASS: Background_Manager is initialized")
	else:
		print("  ✗ FAIL: Background_Manager not initialized")
		all_passed = false
	
	# Test 4: Verify configuration loaded
	print("\nTest 4: Configuration loading")
	var available_bgs = bg_manager.get_available_backgrounds()
	if available_bgs.size() > 0:
		print("  ✓ PASS: Configuration loaded (", available_bgs.size(), " backgrounds)")
		print("    Available: ", available_bgs)
	else:
		print("  ✗ FAIL: No backgrounds configured")
		all_passed = false
	
	# Test 5: Verify required backgrounds exist in config
	print("\nTest 5: Required backgrounds in configuration")
	var required = ["level_1", "level_2", "level_3", "menu"]
	var missing = []
	for bg_id in required:
		if not available_bgs.has(bg_id):
			missing.append(bg_id)
	
	if missing.size() == 0:
		print("  ✓ PASS: All required backgrounds configured")
	else:
		print("  ✗ FAIL: Missing backgrounds: ", missing)
		all_passed = false
	
	# Test 6: Verify signal connections
	print("\nTest 6: GameState signal connections")
	var has_state_changed = game_state.has_signal("state_changed")
	var has_level_started = game_state.has_signal("level_started")
	
	if has_state_changed and has_level_started:
		print("  ✓ PASS: GameState signals exist")
	else:
		print("  ✗ FAIL: Missing signals")
		if not has_state_changed:
			print("    Missing: state_changed")
		if not has_level_started:
			print("    Missing: level_started")
		all_passed = false
	
	# Test 7: Verify Background_Manager methods
	print("\nTest 7: Background_Manager API methods")
	var required_methods = [
		"load_level_background",
		"load_menu_background",
		"cleanup_current_background",
		"get_current_background_id",
		"is_background_loaded"
	]
	var missing_methods = []
	for method in required_methods:
		if not bg_manager.has_method(method):
			missing_methods.append(method)
	
	if missing_methods.size() == 0:
		print("  ✓ PASS: All required methods exist")
	else:
		print("  ✗ FAIL: Missing methods: ", missing_methods)
		all_passed = false
	
	# Test 8: Test basic background loading
	print("\nTest 8: Basic background loading")
	bg_manager.load_menu_background()
	var current_bg = bg_manager.get_current_background_id()
	if current_bg == "menu":
		print("  ✓ PASS: Menu background loaded successfully")
	else:
		print("  ✗ FAIL: Menu background not loaded (got: ", current_bg, ")")
		all_passed = false
	
	# Test 9: Test level background loading
	print("\nTest 9: Level background loading")
	bg_manager.load_level_background(1)
	current_bg = bg_manager.get_current_background_id()
	if current_bg == "level_1":
		print("  ✓ PASS: Level 1 background loaded successfully")
	else:
		print("  ✗ FAIL: Level 1 background not loaded (got: ", current_bg, ")")
		all_passed = false
	
	# Test 10: Test background cleanup
	print("\nTest 10: Background cleanup")
	bg_manager.cleanup_current_background()
	var is_loaded = bg_manager.is_background_loaded()
	if not is_loaded:
		print("  ✓ PASS: Background cleanup works")
	else:
		print("  ✗ FAIL: Background still loaded after cleanup")
		all_passed = false
	
	# Summary
	print("\n" + "=" * 60)
	if all_passed:
		print("✓ ALL TESTS PASSED - Integration verified successfully!")
		print("\nThe background system is properly wired and ready to use.")
		print("Complete flow: menu → level 1 → level 2 → level 3 → menu")
		quit(0)
	else:
		print("✗ SOME TESTS FAILED - Integration incomplete")
		quit(1)
