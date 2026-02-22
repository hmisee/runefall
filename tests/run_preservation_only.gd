extends SceneTree
# Test runner for preservation tests only
# Run with: godot --headless --script tests/run_preservation_only.gd

func _init():
	print("=== Running Preservation Tests Only ===\n")
	
	# Load and run level cleanup preservation tests
	print("\n### Running Level Cleanup Preservation Tests ###")
	var cleanup_preservation_script = load("res://tests/test_level_cleanup_preservation.gd")
	var cleanup_preservation_instance = cleanup_preservation_script.new()
	cleanup_preservation_instance.run_tests()
	cleanup_preservation_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
