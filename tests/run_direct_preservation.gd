extends SceneTree
# Direct test runner
# Run with: godot --headless --script tests/run_direct_preservation.gd

func _init():
	print("=== Direct Preservation Tests ===")
	
	var test_script = load("res://tests/test_preservation_direct.gd")
	test_script.run_all_tests()
	
	print("\n=== Done ===")
	quit()
