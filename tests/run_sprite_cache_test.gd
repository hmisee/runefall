extends SceneTree
# Runner for sprite cache completeness property test
# Run with: godot --headless --script tests/run_sprite_cache_test.gd

func _init():
	print("=== Sprite Cache Completeness Test Runner ===\n")
	
	var test_script = load("res://tests/test_sprite_cache_completeness.gd")
	var test_instance = test_script.new()
	test_instance.run_tests()
	test_instance.queue_free()
	
	print("\n=== Done ===")
	quit()
