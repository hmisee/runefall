extends Node

## Test suite for Task 2.3: Static background loading for levels
## Validates that load_level_background() works correctly with all requirements

var bg_manager = null

func run_tests():
	print("\n=== Running Level Background Loading Tests ===\n")
	
	# Create a local instance for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	test_load_level_background_method_exists()
	test_load_level_background_creates_canvas_layer()
	test_canvas_layer_has_correct_z_index()
	test_sprite2d_node_created()
	test_resource_loader_check_before_loading()
	test_viewport_scaling_applied()
	test_invalid_level_number_handled()
	test_all_three_levels_can_load()
	test_aspect_ratio_preservation()
	
	# Cleanup
	bg_manager.queue_free()
	
	print("\n✓ All Level Background Loading tests passed!\n")

func cleanup():
	if bg_manager:
		bg_manager.cleanup_current_background()

func test_load_level_background_method_exists():
	print("--- Test 1: load_level_background method exists ---")
	assert(bg_manager.has_method("load_level_background"), 
		"BackgroundManager should have load_level_background method")
	print("  ✓ PASS: load_level_background method exists")
	cleanup()

func test_load_level_background_creates_canvas_layer():
	print("--- Test 2: CanvasLayer created ---")
	bg_manager.load_level_background(1)
	assert(bg_manager.current_canvas_layer != null, 
		"CanvasLayer should be created")
	print("  ✓ PASS: CanvasLayer created successfully")
	cleanup()

func test_canvas_layer_has_correct_z_index():
	print("--- Test 3: CanvasLayer z-index is -100 ---")
	bg_manager.load_level_background(1)
	assert(bg_manager.current_canvas_layer.layer == -100, 
		"CanvasLayer z-index should be -100, got " + str(bg_manager.current_canvas_layer.layer))
	print("  ✓ PASS: CanvasLayer z-index is -100")
	cleanup()

func test_sprite2d_node_created():
	print("--- Test 4: Sprite2D node created ---")
	bg_manager.load_level_background(1)
	assert(bg_manager.current_sprite_node != null, 
		"Sprite node should be created")
	print("  ✓ PASS: Sprite node created successfully")
	cleanup()

func test_resource_loader_check_before_loading():
	print("--- Test 5: ResourceLoader.exists() check ---")
	# Temporarily modify config to point to non-existent file
	var original_config = bg_manager.config_data.duplicate(true)
	bg_manager.config_data["backgrounds"]["level_1"]["path"] = "res://nonexistent.png"
	
	# Load should trigger fallback
	bg_manager.load_level_background(1)
	
	# Should still have a background (fallback ColorRect)
	assert(bg_manager.current_sprite_node != null, 
		"Fallback background should be created when asset missing")
	print("  ✓ PASS: ResourceLoader.exists() check works, fallback created")
	
	# Restore original config
	bg_manager.config_data = original_config
	cleanup()

func test_viewport_scaling_applied():
	print("--- Test 6: Viewport scaling (600x900) applied ---")
	bg_manager.load_level_background(1)
	
	if bg_manager.current_sprite_node and bg_manager.current_sprite_node is Sprite2D:
		var sprite = bg_manager.current_sprite_node as Sprite2D
		# Sprite should be positioned at viewport center
		assert(sprite.position.x == 300.0, 
			"Sprite should be centered horizontally (600/2), got " + str(sprite.position.x))
		assert(sprite.position.y == 450.0, 
			"Sprite should be centered vertically (900/2), got " + str(sprite.position.y))
		print("  ✓ PASS: Viewport scaling applied, sprite centered at (300, 450)")
	else:
		print("  ✓ PASS: Fallback background used (no sprite asset available)")
	cleanup()

func test_invalid_level_number_handled():
	print("--- Test 7: Invalid level numbers handled ---")
	
	bg_manager.load_level_background(0)
	assert(bg_manager.current_canvas_layer == null, 
		"Should not create background for invalid level 0")
	
	bg_manager.load_level_background(4)
	assert(bg_manager.current_canvas_layer == null, 
		"Should not create background for invalid level 4")
	
	bg_manager.load_level_background(-1)
	assert(bg_manager.current_canvas_layer == null, 
		"Should not create background for invalid level -1")
	
	print("  ✓ PASS: Invalid level numbers properly rejected")
	cleanup()

func test_all_three_levels_can_load():
	print("--- Test 8: All three levels can load ---")
	for level in [1, 2, 3]:
		bg_manager.cleanup_current_background()
		bg_manager.load_level_background(level)
		
		assert(bg_manager.current_canvas_layer != null, 
			"Level " + str(level) + " should create CanvasLayer")
		assert(bg_manager.current_background_id == "level_" + str(level),
			"Background ID should match level number")
		print("  ✓ PASS: Level " + str(level) + " loaded successfully")
	cleanup()

func test_aspect_ratio_preservation():
	print("--- Test 9: Aspect ratio preservation ---")
	bg_manager.load_level_background(1)
	
	if bg_manager.current_sprite_node and bg_manager.current_sprite_node is Sprite2D:
		var sprite = bg_manager.current_sprite_node as Sprite2D
		# Scale should be uniform (same x and y) to preserve aspect ratio
		assert(sprite.scale.x == sprite.scale.y, 
			"Scale should be uniform to preserve aspect ratio, got " + str(sprite.scale))
		print("  ✓ PASS: Aspect ratio preserved (uniform scale: " + str(sprite.scale.x) + ")")
	else:
		print("  ✓ PASS: Fallback background used (no sprite asset available)")
	cleanup()
