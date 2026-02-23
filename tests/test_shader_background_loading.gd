extends GutTest

## Test shader-based background loading
## Feature: level-and-menu-backgrounds
## Tests Requirements 4.2, 4.5

var background_manager: Node

func before_each():
	# Get the Background_Manager autoload
	background_manager = get_node("/root/BackgroundManager")
	assert_not_null(background_manager, "Background_Manager should be available as autoload")
	
	# Clean up any existing background
	background_manager.cleanup_current_background()

func after_each():
	# Clean up after test
	if background_manager:
		background_manager.cleanup_current_background()

func test_shader_background_type_supported():
	# Test that shader type is recognized as valid
	var config = background_manager.config_data
	assert_not_null(config, "Config should be loaded")
	
	# Verify shader example exists in config
	assert_true(config.has("backgrounds"), "Config should have backgrounds section")
	assert_true(config["backgrounds"].has("_shader_example"), "Config should have shader example")
	
	var shader_config = config["backgrounds"]["_shader_example"]
	assert_eq(shader_config["type"], "shader", "Shader example should have type 'shader'")
	assert_true(shader_config.has("shader_path"), "Shader config should have shader_path")
	assert_true(shader_config.has("shader_params"), "Shader config should have shader_params")

func test_shader_file_exists():
	# Test that shader files exist
	assert_true(ResourceLoader.exists("res://assets/shaders/animated_background.gdshader"), 
		"Animated background shader should exist")
	assert_true(ResourceLoader.exists("res://assets/shaders/pulsing_background.gdshader"), 
		"Pulsing background shader should exist")

func test_shader_can_be_loaded():
	# Test that shader can be loaded as a resource
	var shader = load("res://assets/shaders/animated_background.gdshader")
	assert_not_null(shader, "Shader should load successfully")
	assert_true(shader is Shader, "Loaded resource should be a Shader")

func test_shader_background_loading_with_texture():
	# Create a temporary shader background config
	var test_config = {
		"type": "shader",
		"path": "res://assets/backgrounds/level_1_bg.png",
		"shader_path": "res://assets/shaders/pulsing_background.gdshader",
		"opacity": 0.9,
		"shader_params": {
			"pulse_speed": 2.0,
			"pulse_intensity": 0.5,
			"pulse_color": "#FF8800"
		}
	}
	
	# Temporarily add to config
	background_manager.config_data["backgrounds"]["test_shader"] = test_config
	
	# Load the shader background
	background_manager._load_background("test_shader")
	
	# Wait a frame for loading to complete
	await get_tree().process_frame
	
	# Verify background loaded
	assert_eq(background_manager.get_current_background_id(), "test_shader", 
		"Current background should be test_shader")
	assert_true(background_manager.is_background_loaded(), 
		"Background should be loaded")
	
	# Verify sprite has shader material
	var sprite = background_manager.current_sprite_node
	assert_not_null(sprite, "Sprite node should exist")
	assert_not_null(sprite.material, "Sprite should have material")
	assert_true(sprite.material is ShaderMaterial, "Material should be ShaderMaterial")
	
	# Verify shader parameters were set
	var material = sprite.material as ShaderMaterial
	assert_almost_eq(material.get_shader_parameter("pulse_speed"), 2.0, 0.01, 
		"pulse_speed parameter should be set")
	assert_almost_eq(material.get_shader_parameter("pulse_intensity"), 0.5, 0.01, 
		"pulse_intensity parameter should be set")
	
	# Clean up
	background_manager.config_data["backgrounds"].erase("test_shader")

func test_shader_background_loading_without_texture():
	# Test shader background with no base texture (should create white texture)
	var test_config = {
		"type": "shader",
		"path": "",  # No texture
		"shader_path": "res://assets/shaders/pulsing_background.gdshader",
		"opacity": 1.0,
		"shader_params": {
			"pulse_speed": 1.0
		}
	}
	
	# Temporarily add to config
	background_manager.config_data["backgrounds"]["test_shader_no_tex"] = test_config
	
	# Load the shader background
	background_manager._load_background("test_shader_no_tex")
	
	# Wait a frame for loading to complete
	await get_tree().process_frame
	
	# Verify background loaded with generated texture
	assert_eq(background_manager.get_current_background_id(), "test_shader_no_tex", 
		"Current background should be test_shader_no_tex")
	assert_true(background_manager.is_background_loaded(), 
		"Background should be loaded")
	
	var sprite = background_manager.current_sprite_node
	assert_not_null(sprite, "Sprite node should exist")
	assert_not_null(sprite.texture, "Sprite should have texture (generated)")
	assert_not_null(sprite.material, "Sprite should have shader material")
	
	# Clean up
	background_manager.config_data["backgrounds"].erase("test_shader_no_tex")

func test_shader_background_missing_shader_path():
	# Test error handling when shader_path is missing
	var test_config = {
		"type": "shader",
		"path": "res://assets/backgrounds/level_1_bg.png",
		"opacity": 1.0
		# Missing shader_path
	}
	
	# Temporarily add to config
	background_manager.config_data["backgrounds"]["test_no_shader"] = test_config
	
	# Load should fail and use fallback
	background_manager._load_background("test_no_shader")
	
	# Wait a frame
	await get_tree().process_frame
	
	# Should have loaded fallback
	assert_eq(background_manager.get_current_background_id(), "test_no_shader", 
		"Should have fallback background")
	
	# Clean up
	background_manager.config_data["backgrounds"].erase("test_no_shader")

func test_shader_background_invalid_shader_path():
	# Test error handling when shader file doesn't exist
	var test_config = {
		"type": "shader",
		"path": "res://assets/backgrounds/level_1_bg.png",
		"shader_path": "res://assets/shaders/nonexistent.gdshader",
		"opacity": 1.0,
		"shader_params": {}
	}
	
	# Temporarily add to config
	background_manager.config_data["backgrounds"]["test_bad_shader"] = test_config
	
	# Load should fail and use fallback
	background_manager._load_background("test_bad_shader")
	
	# Wait a frame
	await get_tree().process_frame
	
	# Should have loaded fallback
	assert_eq(background_manager.get_current_background_id(), "test_bad_shader", 
		"Should have fallback background")
	
	# Clean up
	background_manager.config_data["backgrounds"].erase("test_bad_shader")

func test_shader_params_color_conversion():
	# Test that color strings are converted to Color objects
	var test_config = {
		"type": "shader",
		"path": "res://assets/backgrounds/level_1_bg.png",
		"shader_path": "res://assets/shaders/animated_background.gdshader",
		"opacity": 1.0,
		"shader_params": {
			"color_tint": "#FF0000"  # Red color as string
		}
	}
	
	# Temporarily add to config
	background_manager.config_data["backgrounds"]["test_color"] = test_config
	
	# Load the shader background
	background_manager._load_background("test_color")
	
	# Wait a frame
	await get_tree().process_frame
	
	# Verify color was converted and applied
	var sprite = background_manager.current_sprite_node
	assert_not_null(sprite, "Sprite should exist")
	
	var material = sprite.material as ShaderMaterial
	var color_param = material.get_shader_parameter("color_tint")
	assert_not_null(color_param, "color_tint parameter should be set")
	assert_true(color_param is Color, "color_tint should be a Color object")
	
	# Clean up
	background_manager.config_data["backgrounds"].erase("test_color")
