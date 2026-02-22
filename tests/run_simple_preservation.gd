extends SceneTree
# Simple test runner
# Run with: godot --headless --script tests/run_simple_preservation.gd

func _init():
	print("=== Simple Preservation Tests ===\n")
	
	var test_script = load("res://tests/test_preservation_simple.gd")
	var test_instance = test_script.new()
	test_instance.run_tests()
	test_instance.queue_free()
	
	print("\n=== Done ===")
	quit()
