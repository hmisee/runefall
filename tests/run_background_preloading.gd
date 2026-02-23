extends SceneTree

func _init():
	# Load and run the test
	var test = load("res://tests/test_background_preloading.gd").new()
	root.add_child(test)
	test.run_tests()
	
	# Exit
	quit()
