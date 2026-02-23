extends SceneTree

## Test runner for transition integration tests
## Run with: godot --headless -s tests/run_transition_integration.gd

func _init():
	var test_script = load("res://tests/test_transition_integration.gd")
	var test_instance = test_script.new()
	root.add_child(test_instance)
	
	# Run tests synchronously
	test_instance.run_tests()
	
	# Cleanup
	test_instance.queue_free()
	
	# Quit immediately
	call_deferred("quit")
