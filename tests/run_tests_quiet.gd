extends SceneTree
# Ultra-quiet test runner - only shows failures
# Run with: godot --headless --script tests/run_tests_quiet.gd

var total = 0
var passed = 0
var failed = 0
var failed_tests = []

func _init():
	print("Running tests...")
	
	var tests = [
		"test_level_cleanup_exploration",
		"test_level_cleanup_preservation", 
		"test_level_progression_bugs_exploration",
		"test_level_progression_bugs_preservation",
		"test_sprite_cache_completeness",
		"test_sprite_scaling_simple",
		"test_type_sprite_correspondence",
		"test_sprite_node_usage",
		"test_sprite_orientation_preservation",
		"test_background_manager_config",
		"test_level_background_loading",
		"test_menu_background_loading",
		"test_gamestate_signal_integration",
		"test_z_ordering",
		"test_frame_animation_loading",
		"test_complete_integration",
		"test_performance_minimal"
	]
	
	for test_name in tests:
		run_test(test_name)
	
	# Results
	print("\n%d/%d tests passed" % [passed, total])
	
	if failed > 0:
		print("\nFailed tests:")
		for name in failed_tests:
			print("  - " + name)
		quit(1)
	else:
		print("✓ All tests passed")
		quit(0)

func run_test(name: String):
	total += 1
	
	var script = load("res://tests/" + name + ".gd")
	if not script:
		failed += 1
		failed_tests.append(name + " (not found)")
		return
	
	var instance = script.new()
	if not instance:
		failed += 1
		failed_tests.append(name + " (instantiation failed)")
		return
	
	if instance.has_method("run_tests"):
		instance.run_tests()
	
	passed += 1
	instance.queue_free()
