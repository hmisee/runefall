extends SceneTree
# Command-line test runner
# Run with: godot --headless --script tests/run_tests.gd

func _init():
	print("=== Runefall Test Runner ===\n")
	
	# Load and run level cleanup exploration tests
	print("\n### Running Level Cleanup Exploration Tests ###")
	var cleanup_exploration_script = load("res://tests/test_level_cleanup_exploration.gd")
	var cleanup_exploration_instance = cleanup_exploration_script.new()
	cleanup_exploration_instance.run_tests()
	cleanup_exploration_instance.queue_free()
	
	# Load and run level cleanup preservation tests
	print("\n### Running Level Cleanup Preservation Tests ###")
	var cleanup_preservation_script = load("res://tests/test_level_cleanup_preservation.gd")
	var cleanup_preservation_instance = cleanup_preservation_script.new()
	cleanup_preservation_instance.run_tests()
	cleanup_preservation_instance.queue_free()
	
	# Load and run level progression bugs exploration tests
	print("\n### Running Level Progression Bugs Exploration Tests ###")
	var progression_exploration_script = load("res://tests/test_level_progression_bugs_exploration.gd")
	var progression_exploration_instance = progression_exploration_script.new()
	progression_exploration_instance.run_tests()
	progression_exploration_instance.queue_free()
	
	# Load and run level progression bugs preservation tests
	print("\n### Running Level Progression Bugs Preservation Tests ###")
	var progression_preservation_script = load("res://tests/test_level_progression_bugs_preservation.gd")
	var progression_preservation_instance = progression_preservation_script.new()
	progression_preservation_instance.run_tests()
	progression_preservation_instance.queue_free()
	
	# Load and run sprite cache completeness tests
	print("\n### Running Sprite Cache Completeness Tests ###")
	var sprite_cache_script = load("res://tests/test_sprite_cache_completeness.gd")
	var sprite_cache_instance = sprite_cache_script.new()
	sprite_cache_instance.run_tests()
	sprite_cache_instance.queue_free()
	
	# Load and run sprite scaling and positioning tests
	print("\n### Running Sprite Scaling and Positioning Tests ###")
	var sprite_scaling_script = load("res://tests/test_sprite_scaling_simple.gd")
	var sprite_scaling_instance = sprite_scaling_script.new()
	sprite_scaling_instance.run_tests()
	sprite_scaling_instance.queue_free()
	
	# Load and run type-sprite correspondence tests
	print("\n### Running Type-Sprite Correspondence Tests ###")
	var type_sprite_script = load("res://tests/test_type_sprite_correspondence.gd")
	var type_sprite_instance = type_sprite_script.new()
	type_sprite_instance.run_tests()
	type_sprite_instance.queue_free()
	
	# Load and run sprite node usage tests
	print("\n### Running Sprite Node Usage Tests ###")
	var sprite_node_script = load("res://tests/test_sprite_node_usage.gd")
	var sprite_node_instance = sprite_node_script.new()
	sprite_node_instance.run_tests()
	sprite_node_instance.queue_free()
	
	# Load and run sprite orientation preservation tests
	print("\n### Running Sprite Orientation Preservation Tests ###")
	var sprite_orientation_script = load("res://tests/test_sprite_orientation_preservation.gd")
	var sprite_orientation_instance = sprite_orientation_script.new()
	sprite_orientation_instance.run_tests()
	sprite_orientation_instance.queue_free()
	
	# Load and run background manager configuration tests
	print("\n### Running Background Manager Configuration Tests ###")
	var background_config_script = load("res://tests/test_background_manager_config.gd")
	var background_config_instance = background_config_script.new()
	background_config_instance.run_tests()
	background_config_instance.queue_free()
	
	# Load and run level background loading tests
	print("\n### Running Level Background Loading Tests ###")
	var level_bg_loading_script = load("res://tests/test_level_background_loading.gd")
	var level_bg_loading_instance = level_bg_loading_script.new()
	level_bg_loading_instance.run_tests()
	level_bg_loading_instance.queue_free()
	
	# Load and run menu background loading tests
	print("\n### Running Menu Background Loading Tests ###")
	var menu_bg_loading_script = load("res://tests/test_menu_background_loading.gd")
	var menu_bg_loading_instance = menu_bg_loading_script.new()
	menu_bg_loading_instance.run_tests()
	menu_bg_loading_instance.queue_free()
	
	# Load and run GameState signal integration tests
	print("\n### Running GameState Signal Integration Tests ###")
	var gamestate_signal_script = load("res://tests/test_gamestate_signal_integration.gd")
	var gamestate_signal_instance = gamestate_signal_script.new()
	gamestate_signal_instance.run_tests()
	gamestate_signal_instance.queue_free()
	
	# Load and run z-ordering tests
	print("\n### Running Z-Ordering Tests ###")
	var z_ordering_script = load("res://tests/test_z_ordering.gd")
	var z_ordering_instance = z_ordering_script.new()
	z_ordering_instance.run_tests()
	z_ordering_instance.queue_free()
	
	# Load and run frame animation loading tests
	print("\n### Running Frame Animation Loading Tests ###")
	var frame_animation_script = load("res://tests/test_frame_animation_loading.gd")
	var frame_animation_instance = frame_animation_script.new()
	frame_animation_instance.run_tests()
	frame_animation_instance.queue_free()
	
	# Load and run complete integration tests
	print("\n### Running Complete Background Integration Tests ###")
	var complete_integration_script = load("res://tests/test_complete_integration.gd")
	var complete_integration_instance = complete_integration_script.new()
	complete_integration_instance.run_tests()
	complete_integration_instance.queue_free()
	
	# Load and run performance validation tests
	print("\n### Running Performance Validation Tests ###")
	var performance_script = load("res://tests/test_performance_minimal.gd")
	var performance_instance = performance_script.new()
	# Note: This test runs in its own _init() and calls quit()
	# So we don't need to call run_tests() or queue_free()
	
	# Exit
	print("\n=== Tests Complete ===")
	quit()
