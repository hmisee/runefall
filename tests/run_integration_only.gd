extends SceneTree
# Run only the complete integration test
# Run with: godot --headless --script tests/run_integration_only.gd

func _init():
	print("=== Running Complete Integration Test Only ===\n")
	
	# Load and run complete integration tests
	var complete_integration_script = load("res://tests/test_complete_integration.gd")
	var complete_integration_instance = complete_integration_script.new()
	complete_integration_instance.run_tests()
	complete_integration_instance.queue_free()
	
	# Exit
	print("\n=== Test Complete ===")
	quit()
