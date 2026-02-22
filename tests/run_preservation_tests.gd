extends SceneTree
# Command-line test runner for preservation tests only
# Run with: godot --headless --script tests/run_preservation_tests.gd

func _init():
	print("=== Runefall Preservation Test Runner ===\n")
	
	# Load and run preservation tests
	var preservation_test_script = load("res://tests/test_preservation_properties.gd")
	var preservation_test_instance = preservation_test_script.new()
	preservation_test_instance.run_tests()
	preservation_test_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
