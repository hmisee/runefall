extends Node

# Unit tests for Background_Manager fallback system
# Tests Requirements 1.5 and 10.5

var test_passed = true
var background_manager = null

func _ready():
	print("=== Background Fallback System Tests ===\n")
	
	# Get Background_Manager singleton
	background_manager = get_node("/root/BackgroundManager")
	if not background_manager:
		print("✗ Background_Manager not found!")
		test_passed = false
		get_tree().quit(1)
		return
	
	# Run tests
	await test_show_fallback_background_method()
	test_has_background_asset_method()
	await test_fallback_color_rect_creation()
	test_background_load_failed_signal()
	
	# Report results
	if test_passed:
		print("\n✓ All background fallback tests passed!")
		get_tree().quit(0)
	else:
		print("\n✗ Some tests failed")
		get_tree().quit(1)

func test_show_fallback_background_method():
	print("Test: show_fallback_background(color) method exists and works")
	
	# Test with a custom color
	var test_color = Color(1.0, 0.0, 0.0, 1.0)  # Red
	background_manager.show_fallback_background(test_color)
	
	# Wait for deferred calls to complete
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Verify canvas layer was created
	if not background_manager.current_canvas_layer:
		print("  ✗ Canvas layer not created")
		test_passed = false
		return
	
	# Verify z-index is correct
	if background_manager.current_canvas_layer.layer != -100:
		print("  ✗ Canvas layer z-index is not -100")
		test_passed = false
		return
	
	# Verify ColorRect was created
	if not background_manager.current_sprite_node:
		print("  ✗ ColorRect node not created")
		test_passed = false
		return
	
	if not background_manager.current_sprite_node is ColorRect:
		print("  ✗ Sprite node is not a ColorRect")
		test_passed = false
		return
	
	# Verify color matches
	var color_rect = background_manager.current_sprite_node as ColorRect
	if not color_rect.color.is_equal_approx(test_color):
		print("  ✗ ColorRect color doesn't match (expected: ", test_color, ", got: ", color_rect.color, ")")
		test_passed = false
		return
	
	# Verify size is correct
	if color_rect.size != Vector2(600, 900):
		print("  ✗ ColorRect size incorrect (expected: 600x900, got: ", color_rect.size, ")")
		test_passed = false
		return
	
	print("  ✓ show_fallback_background() works correctly")
	
	# Cleanup
	background_manager.cleanup_current_background()

func test_has_background_asset_method():
	print("Test: has_background_asset(background_id) method")
	
	# Test with valid background IDs (these should exist in config)
	var level_1_exists = background_manager.has_background_asset("level_1")
	var level_2_exists = background_manager.has_background_asset("level_2")
	var level_3_exists = background_manager.has_background_asset("level_3")
	
	# Note: Assets may not exist yet, but method should return boolean
	if typeof(level_1_exists) != TYPE_BOOL:
		print("  ✗ has_background_asset() doesn't return boolean")
		test_passed = false
		return
	
	# Test with invalid background ID
	var invalid_exists = background_manager.has_background_asset("nonexistent_background")
	if invalid_exists != false:
		print("  ✗ has_background_asset() should return false for nonexistent backgrounds")
		test_passed = false
		return
	
	print("  ✓ has_background_asset() returns correct boolean values")

func test_fallback_color_rect_creation():
	print("Test: Fallback creates ColorRect nodes")
	
	# Show fallback with blue color
	var test_color = Color(0.0, 0.0, 1.0, 1.0)  # Blue
	background_manager.show_fallback_background(test_color)
	
	# Wait for deferred calls to complete
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Verify it's a ColorRect
	if not background_manager.current_sprite_node is ColorRect:
		print("  ✗ Fallback didn't create ColorRect")
		test_passed = false
		return
	
	# Verify it's in the scene tree
	if not background_manager.current_sprite_node.is_inside_tree():
		print("  ✗ ColorRect not added to scene tree")
		test_passed = false
		return
	
	print("  ✓ Fallback correctly creates ColorRect nodes")
	
	# Cleanup
	background_manager.cleanup_current_background()

func test_background_load_failed_signal():
	print("Test: background_load_failed signal exists")
	
	# Verify signal exists
	if not background_manager.has_signal("background_load_failed"):
		print("  ✗ background_load_failed signal not found")
		test_passed = false
		return
	
	print("  ✓ background_load_failed signal exists")
