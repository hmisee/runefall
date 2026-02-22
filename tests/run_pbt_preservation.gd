extends SceneTree
# Command-line test runner for property-based preservation tests
# Run with: godot --headless --script tests/run_pbt_preservation.gd

func _init():
	print("=== Runefall Property-Based Preservation Test Runner ===\n")
	
	# Load and run PBT preservation tests
	var pbt_test_script = load("res://tests/test_preservation_pbt.gd")
	var pbt_test_instance = pbt_test_script.new()
	pbt_test_instance.run_tests()
	pbt_test_instance.queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
