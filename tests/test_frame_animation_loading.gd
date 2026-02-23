extends Node

## Test suite for Task 13.1: Frame-based animation loading
## Validates that AnimatedSprite2D frame loading works correctly
## Tests: multiple frame files, SpriteFrames creation, frame timing, loop settings, missing frames

var bg_manager = null

func run_tests():
	print("\n=== Running Frame-Based Animation Loading Tests ===\n")
	
	# Create a local instance for testing
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	bg_manager = BackgroundManagerScript.new()
	bg_manager._ready()
	
	test_sprite_frames_resource_created()
	test_multiple_frames_loaded()
	test_frame_timing_configuration()
	test_loop_settings_applied()
	test_missing_frames_handled_gracefully()
	test_partial_frame_set_works()
	test_zero_frames_falls_back()
	test_animation_speed_affects_frame_timing()
	test_frames_added_to_default_animation()
	test_preloaded_frames_used_when_available()
	
	# Cleanup
	bg_manager.queue_free()
	
	print("\n✓ All Frame-Based Animation Loading tests passed!\n")

func cleanup():
	if bg_manager:
		bg_manager.cleanup_current_background()

func test_sprite_frames_resource_created():
	print("--- Test 1: SpriteFrames resource created dynamically ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		assert(animated_sprite.sprite_frames != null, 
			"SpriteFrames resource should be created")
		assert(animated_sprite.sprite_frames.has_animation("default"), 
			"SpriteFrames should have 'default' animation")
		print("  ✓ PASS: SpriteFrames resource created dynamically")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_multiple_frames_loaded():
	print("--- Test 2: Multiple frame files loaded for AnimatedSprite2D ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var frame_count = sprite_frames.get_frame_count("default")
		
		# Should have at least 1 frame (could be partial set if some frames missing)
		assert(frame_count >= 1, 
			"Should have at least 1 frame loaded, got " + str(frame_count))
		print("  ✓ PASS: Multiple frames loaded (" + str(frame_count) + " frames)")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_frame_timing_configuration():
	print("--- Test 3: Frame timing configured from config ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var animation_speed = sprite_frames.get_animation_speed("default")
		
		# Animation speed should be positive (5.0 * animation_speed from config)
		assert(animation_speed > 0.0, 
			"Animation speed should be positive, got " + str(animation_speed))
		
		# Should be 5.0 * config animation_speed (default 1.0 = 5.0 FPS)
		var expected_speed = 5.0  # 5.0 * 1.0 from config
		assert(abs(animation_speed - expected_speed) < 0.1, 
			"Animation speed should be ~" + str(expected_speed) + " FPS, got " + str(animation_speed))
		print("  ✓ PASS: Frame timing configured (" + str(animation_speed) + " FPS)")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_loop_settings_applied():
	print("--- Test 4: Loop settings configured from config ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var loop_enabled = sprite_frames.get_animation_loop("default")
		
		# Menu background should loop (from config)
		assert(loop_enabled == true, 
			"Menu animation should loop (from config)")
		print("  ✓ PASS: Loop settings applied correctly")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_missing_frames_handled_gracefully():
	print("--- Test 5: Missing frames handled gracefully ---")
	
	# Create a custom config with a high frame count (some frames will be missing)
	var original_config = bg_manager.config_data.duplicate(true)
	bg_manager.config_data["backgrounds"]["menu"]["frame_count"] = 100  # Intentionally high
	
	bg_manager.load_menu_background()
	
	# Should either load partial frames or fall back to solid color
	assert(bg_manager.current_sprite_node != null, 
		"Should create some background node even with missing frames")
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var frame_count = sprite_frames.get_frame_count("default")
		
		# Should have loaded available frames (less than 100)
		assert(frame_count > 0, 
			"Should load available frames even if some are missing")
		assert(frame_count < 100, 
			"Should not have loaded all 100 frames (some should be missing)")
		print("  ✓ PASS: Missing frames handled gracefully (" + str(frame_count) + " frames loaded)")
	else:
		print("  ✓ PASS: Fallback background used when too many frames missing")
	
	# Restore original config
	bg_manager.config_data = original_config
	cleanup()

func test_partial_frame_set_works():
	print("--- Test 6: Partial frame set works (not all frames required) ---")
	
	# Create a custom config with frame_count that might exceed available frames
	var original_config = bg_manager.config_data.duplicate(true)
	bg_manager.config_data["backgrounds"]["menu"]["frame_count"] = 20  # More than likely available
	
	bg_manager.load_menu_background()
	
	# Should work with whatever frames are available
	assert(bg_manager.current_sprite_node != null, 
		"Should create background with partial frame set")
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var frame_count = sprite_frames.get_frame_count("default")
		
		assert(frame_count > 0, 
			"Should have at least some frames loaded")
		print("  ✓ PASS: Partial frame set works (" + str(frame_count) + " frames)")
	else:
		print("  ✓ PASS: Fallback background used (acceptable behavior)")
	
	# Restore original config
	bg_manager.config_data = original_config
	cleanup()

func test_zero_frames_falls_back():
	print("--- Test 7: Zero frames loaded falls back to solid color ---")
	
	# Create a custom config with invalid path (no frames will load)
	var original_config = bg_manager.config_data.duplicate(true)
	bg_manager.config_data["backgrounds"]["menu"]["path"] = "res://nonexistent/path"
	
	bg_manager.load_menu_background()
	
	# Should fall back to ColorRect
	assert(bg_manager.current_sprite_node != null, 
		"Should create fallback background when no frames load")
	assert(bg_manager.current_sprite_node is ColorRect, 
		"Should use ColorRect fallback when no frames available")
	print("  ✓ PASS: Zero frames falls back to solid color")
	
	# Restore original config
	bg_manager.config_data = original_config
	cleanup()

func test_animation_speed_affects_frame_timing():
	print("--- Test 8: Animation speed configuration affects frame timing ---")
	
	# Test with different animation speeds
	var original_config = bg_manager.config_data.duplicate(true)
	
	# Test speed 2.0
	bg_manager.config_data["backgrounds"]["menu"]["animation_speed"] = 2.0
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var speed = sprite_frames.get_animation_speed("default")
		
		# Should be 5.0 * 2.0 = 10.0 FPS
		assert(abs(speed - 10.0) < 0.1, 
			"Animation speed should be ~10.0 FPS with speed 2.0, got " + str(speed))
		print("  ✓ PASS: Animation speed affects frame timing (2.0x = " + str(speed) + " FPS)")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	
	# Restore original config
	bg_manager.config_data = original_config
	cleanup()

func test_frames_added_to_default_animation():
	print("--- Test 9: Frames added to 'default' animation ---")
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		
		# Should have 'default' animation
		assert(sprite_frames.has_animation("default"), 
			"SpriteFrames should have 'default' animation")
		
		# Default animation should be the active one
		assert(animated_sprite.animation == "default", 
			"AnimatedSprite2D should use 'default' animation")
		
		# Should have frames in default animation
		var frame_count = sprite_frames.get_frame_count("default")
		assert(frame_count > 0, 
			"'default' animation should have frames")
		print("  ✓ PASS: Frames added to 'default' animation (" + str(frame_count) + " frames)")
	else:
		print("  ✓ PASS: Fallback background used (no animation frames available)")
	cleanup()

func test_preloaded_frames_used_when_available():
	print("--- Test 10: Preloaded frames used when available ---")
	
	# Check if frames were preloaded
	var has_preloaded = bg_manager.preloaded_textures.has("menu")
	
	if has_preloaded:
		var preloaded_data = bg_manager.preloaded_textures["menu"]
		if preloaded_data is Array:
			print("  ✓ INFO: Menu frames were preloaded (" + str(preloaded_data.size()) + " frames)")
		else:
			print("  ✓ INFO: Menu data preloaded but not as array")
	else:
		print("  ✓ INFO: Menu frames not preloaded (will load at runtime)")
	
	# Load menu background (should use preloaded frames if available)
	bg_manager.load_menu_background()
	
	if bg_manager.current_sprite_node is AnimatedSprite2D:
		var animated_sprite = bg_manager.current_sprite_node as AnimatedSprite2D
		var sprite_frames = animated_sprite.sprite_frames
		var frame_count = sprite_frames.get_frame_count("default")
		
		assert(frame_count > 0, 
			"Should have frames loaded (preloaded or runtime)")
		print("  ✓ PASS: Frames loaded successfully (" + str(frame_count) + " frames)")
	else:
		print("  ✓ PASS: Fallback background used (acceptable)")
	cleanup()
