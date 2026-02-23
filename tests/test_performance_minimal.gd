extends SceneTree

## Minimal performance validation test
## Tests Task 14.2 requirements: 7.4 (memory usage)

const MAX_MEMORY_MB = 50

func _init():
	print("\n=== Background_Manager Performance Validation (Minimal) ===\n")
	
	# Load BackgroundManager script
	var BackgroundManagerScript = load("res://scripts/background_manager.gd")
	var background_manager = BackgroundManagerScript.new()
	
	# Manually load config without full initialization
	background_manager.load_config()
	
	# Manually preload backgrounds
	background_manager._preload_all_backgrounds()
	
	# Test: Memory usage under limit
	print("--- Test: Memory usage stays under 50MB ---")
	var memory_bytes = background_manager.get_memory_usage()
	var memory_mb = float(memory_bytes) / (1024.0 * 1024.0)
	
	print("  Total background memory usage: %.2f MB" % memory_mb)
	print("  Target limit: %d MB" % MAX_MEMORY_MB)
	print("  Preloaded backgrounds: %d" % background_manager.preloaded_textures.size())
	
	assert(memory_mb < MAX_MEMORY_MB, 
		"Memory usage (%.2f MB) should be under %d MB" % [memory_mb, MAX_MEMORY_MB])
	
	print("  ✓ PASS: Memory usage is within limits (%.2f MB / %d MB)" % [memory_mb, MAX_MEMORY_MB])
	
	# Test: Performance metrics accessible
	print("\n--- Test: Performance metrics are logged ---")
	
	assert(background_manager.has_method("get_memory_usage"),
		"BackgroundManager should have get_memory_usage() method")
	print("  ✓ get_memory_usage() method exists")
	
	assert(background_manager.preloaded_textures is Dictionary,
		"Preloaded textures should be tracked")
	print("  ✓ Preloaded textures tracked as Dictionary")
	
	assert(memory_bytes >= 0, "Memory usage should be non-negative")
	print("  ✓ Memory tracking active: %.2f MB" % memory_mb)
	
	print("  ✓ PASS: Performance metrics are logged and accessible")
	
	# FPS validation note
	print("\n--- Note: FPS Validation ---")
	print("  ℹ INFO: FPS validation requires active gameplay scene")
	print("  ℹ INFO: Target: 60 FPS for gameplay (Requirement 7.1)")
	print("  ℹ INFO: Target: 30+ FPS for menu animation (Requirement 7.2)")
	print("  ℹ INFO: Validate FPS during manual gameplay testing")
	
	# Cleanup
	background_manager.queue_free()
	
	print("\n✓ All performance validation tests passed!")
	print("✓ Memory usage: %.2f MB / %d MB" % [memory_mb, MAX_MEMORY_MB])
	print("✓ Performance metrics: Accessible and logged")
	print("\n=== Performance Validation Complete ===\n")
	
	quit()
