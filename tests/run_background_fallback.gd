extends SceneTree

func _init():
	# Load and run the test
	var test_scene = load("res://tests/test_background_fallback.gd")
	var test_instance = test_scene.new()
	root.add_child(test_instance)
