extends SceneTree

## Test runner for background transition tests
## Run with: godot --headless -s tests/run_background_transitions.gd

func _init():
	# Load and run the test
	var test_script = load("res://tests/test_background_transitions.gd")
	var test_instance = test_script.new()
	root.add_child(test_instance)
	
	# Run tests
	await test_instance.run_tests()
	
	# Cleanup and quit
	test_instance.queue_free()
	quit()
