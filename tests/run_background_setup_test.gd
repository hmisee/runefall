extends SceneTree

func _init():
	# This runner will be replaced by the test itself
	pass

func _initialize():
	var test = preload("res://tests/test_background_manager_setup.gd").new()
	root.add_child(test)
