extends SceneTree
# Command-line test runner for sprite scaling and positioning tests
# Run with: godot --headless --script tests/run_sprite_scaling_simple.gd

func _init():
	print("=== Sprite Scaling and Positioning Test Runner ===\n")
	
	# Load and run sprite scaling tests
	var test_script = load("res://tests/test_sprite_scaling_simple.gd")
	var test_instance = test_script.new()
	test_instance.run_tests()
	test_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
