extends SceneTree
# Command-line test runner for Level Progression Bugs Exploration Tests
# Run with: godot --headless --script tests/run_level_progression_exploration.gd

func _init():
	print("=== Runefall - Level Progression Bugs Exploration Test Runner ===\n")
	
	# Load and run level progression bugs exploration tests
	print("\n### Running Level Progression Bugs Exploration Tests ###")
	var exploration_script = load("res://tests/test_level_progression_bugs_exploration.gd")
	var exploration_instance = exploration_script.new()
	exploration_instance.run_tests()
	exploration_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
