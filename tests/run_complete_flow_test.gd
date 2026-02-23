extends SceneTree

## Test runner for complete background flow integration test
## Run with: godot --headless -s tests/run_complete_flow_test.gd

func _init():
	print("Starting Complete Flow Integration Test...")
	print("============================================================")
	
	# Load and run the test
	var test_script = load("res://tests/test_complete_flow.gd")
	var test_instance = test_script.new()
	
	# Add to root so it has access to scene tree
	root.add_child(test_instance)
	
	# Run tests
	await test_instance.run_tests()
	
	# Wait a bit for cleanup
	await create_timer(0.5).timeout
	
	# Cleanup
	test_instance.queue_free()
	
	print("============================================================")
	print("Test execution complete")
	
	# Exit
	quit()
