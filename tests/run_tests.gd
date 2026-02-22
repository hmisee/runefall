extends SceneTree
# Command-line test runner
# Run with: godot --headless --script tests/run_tests.gd

func _init():
	print("=== Runefall Test Runner ===\n")
	
	# Load and run level cleanup exploration tests
	print("\n### Running Level Cleanup Exploration Tests ###")
	var cleanup_exploration_script = load("res://tests/test_level_cleanup_exploration.gd")
	var cleanup_exploration_instance = cleanup_exploration_script.new()
	cleanup_exploration_instance.run_tests()
	cleanup_exploration_instance.queue_free()
	
	# Load and run level cleanup preservation tests
	print("\n### Running Level Cleanup Preservation Tests ###")
	var cleanup_preservation_script = load("res://tests/test_level_cleanup_preservation.gd")
	var cleanup_preservation_instance = cleanup_preservation_script.new()
	cleanup_preservation_instance.run_tests()
	cleanup_preservation_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
