extends SceneTree

func _init():
	print("=== Simple Test Runner ===\n")
	
	var test_script = load("res://tests/test_simple_preservation.gd")
	var test_instance = test_script.new()
	test_instance.run_tests()
	test_instance.queue_free()
	
	print("\n=== Done ===")
	quit()
