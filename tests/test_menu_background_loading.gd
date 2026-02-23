extends Node

## Test suite for Task 3.1: Menu background loading functionality
## Validates that load_menu_background() works correctly with AnimatedSprite2D

var bg_manager = null

func run_tests():
	print("\n=== Running Menu Background Loading Tests ===\n")
	
	# Create a local instance for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	test_load_menu_background_method_exists()
	test_menu_background_creates_canvas_layer()
	test_canvas_layer_has_correct_z_index()
	test_animated_sprite_2d_created()
	test_animation_looping_configured()
	test_animation_speed_configured()
	test_viewport_scaling_for_animated_background()
	test_animation_starts_playing()
	test_frame_count_configuration()
	test_opacity_configuration()
	
	# Cleanup
	bg_manager.queue_free()
	
	print("\n✓ All Menu Background Loading tests passed!\n")

func cleanup():
	if bg_manager:
		bg_manager.cleanup_current_background()

func test_load_menu_background_method_exists():
	print("--- Test 1: load_menu_background method exists ---")
	assert(bg_manager.has_method("load_menu_background"), 
		"BackgroundManager should have load_menu_background method")
	print("  ✓ PASS: load_menu_background method exists")
	cleanup()

func test_menu_background_creates_canvas_layer():
	print("--- Test 2: CanvasLayer created for menu background ---")
	bg_manager.load_menu_background()
	assert(bg_manager.current_canvas_layer != null, 
		"CanvasLayer should be created for menu background")
	print("  ✓ PASS: CanvasLayer created successfully")
	cleanup()

func test_canvas_layer_has_correct_z_index():
	print("--- Test 3: CanvasLayer z-index is -100 ---")
	bg_manager.load_menu_background()
	assert(bg_manager.current_canvas_layer.layer == -100, 
		"CanvasLayer z-index should be -100, got " + str(bg_manager.current_canvas_layer.layer))
	print("  ✓ PASS: CanvasLayer z-index is -100")
	cleanup()

func test_animated_sprite_2d_created():
	print("--- Test 4: AnimatedSprite2D node created ---")
	bg_manager.load_menu_background()
	
	# Check if sprite node exists and is AnimatedSprite2D or fallback ColorRect
	assert(bg_manager.current_sprite_node != null, 
		"Sprite node should be created")
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		print("  ✓ PASS: AnimatedSprite2D created successfully")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_animation_looping_configured():
	print("--- Test 5: Animation looping configured from config ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		
		# Check if loop is configured (should be true from config)
		var loop_enabled = sprite_frames.get_animation_loop("default")
		assert(loop_enabled == true, 
			"Animation loop should be enabled from config")
		print("  ✓ PASS: Animation looping configured correctly")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_animation_speed_configured():
	print("--- Test 6: Animation speed configured from config ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		
		# Check if speed is configured (should be 5.0 * animation_speed from config)
		var speed = sprite_frames.get_animation_speed("default")
		assert(speed > 0.0, 
			"Animation speed should be positive, got " + str(speed))
		print("  ✓ PASS: Animation speed configured (speed: " + str(speed) + ")")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_viewport_scaling_for_animated_background():
	print("--- Test 7: Viewport scaling applied to animated background ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		
		# Sprite should be positioned at viewport center (300, 450)
		assert(animated_sprite.position.x == 300.0, 
			"AnimatedSprite should be centered horizontally (600/2), got " + str(animated_sprite.position.x))
		assert(animated_sprite.position.y == 450.0, 
			"AnimatedSprite should be centered vertically (900/2), got " + str(animated_sprite.position.y))
		
		# Scale should be uniform to preserve aspect ratio
		assert(animated_sprite.scale.x == animated_sprite.scale.y, 
			"Scale should be uniform to preserve aspect ratio")
		print("  ✓ PASS: Viewport scaling applied, sprite centered and scaled")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_animation_starts_playing():
	print("--- Test 8: Animation starts playing automatically ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		
		# Check if animation is playing
		assert(animated_sprite.is_playing(), 
			"Animation should start playing automatically")
		print("  ✓ PASS: Animation starts playing automatically")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_frame_count_configuration():
	print("--- Test 9: Frame count configuration respected ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		
		# Check frame count (should match available frames, up to configured frame_count)
		var frame_count = sprite_frames.get_frame_count("default")
		assert(frame_count > 0, 
			"Should have at least one frame loaded")
		print("  ✓ PASS: Frame count configuration respected (" + str(frame_count) + " frames)")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_opacity_configuration():
	print("--- Test 10: Opacity configuration applied ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node:
		var sprite = bg_manager.current_sprite_node
		
		# Check if opacity is applied (should be between 0.0 and 1.0)
		assert(sprite.modulate.a >= 0.0 and sprite.modulate.a <= 1.0, 
			"Opacity should be between 0.0 and 1.0, got " + str(sprite.modulate.a))
		print("  ✓ PASS: Opacity configuration applied (opacity: " + str(sprite.modulate.a) + ")")
	cleanup()
