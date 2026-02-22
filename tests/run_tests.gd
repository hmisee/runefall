extends SceneTree
# Command-line test runner
# Run with: godot --headless --script tests/run_tests.gd

func _init():
	print("=== Runefall Test Runner ===\n")
	
	# Load and run bug exploration test
	print("\n### Running Bug Exploration Tests ###")
	var bug_test_script = load("res://tests/test_rotation_bug_exploration.gd")
	var bug_test_instance = bug_test_script.new()
	bug_test_instance.run_tests()
	bug_test_instance.queue_free()
	
	# Load and run preservation tests
	print("\n### Running Preservation Property Tests ###")
	var preservation_test_script = load("res://tests/test_preservation_properties.gd")
	var preservation_test_instance = preservation_test_script.new()
	preservation_test_instance.run_tests()
	preservation_test_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
