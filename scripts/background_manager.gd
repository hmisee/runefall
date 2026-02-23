extends Node

## Background_Manager
## Manages static level backgrounds and animated menu backgrounds
## Autoloaded singleton that handles background loading, display, and transitions

# Signals
signal background_loaded(background_id: String)
signal background_load_failed(background_id: String)

# Current background state
var current_background_id: String = ""
var current_canvas_layer: CanvasLayer = null
var current_sprite_node: Node = null
var config_data: Dictionary = {}
var is_initialized: bool = false

# Preloaded textures cache
var preloaded_textures: Dictionary = {}
var total_memory_usage: int = 0

# Configuration file path
const CONFIG_PATH = "res://backgrounds_config.json"

# Viewport size
const VIEWPORT_WIDTH = 600
const VIEWPORT_HEIGHT = 900

func _ready():
	load_config()
	_preload_all_backgrounds()
	is_initialized = true
	_connect_to_game_state()
	print("Background_Manager initialized")

## Connect to GameState signals for automatic background transitions
func _connect_to_game_state() -> void:
	# Wait for GameState to be available (it's an autoload)
	if not has_node("/root/GameState"):
		push_warning("GameState not found, background transitions will not work automatically")
		return
	
	var game_state = get_node("/root/GameState")
	
	# Verify GameState has the expected signals
	if not game_state.has_signal("state_changed"):
		push_error("GameState does not have 'state_changed' signal")
		return
	
	if not game_state.has_signal("level_started"):
		push_error("GameState does not have 'level_started' signal")
		return
	
	# Connect to state changes for menu transitions (check if already connected)
	if not game_state.state_changed.is_connected(_on_game_state_changed):
		var result = game_state.state_changed.connect(_on_game_state_changed)
		if result != OK:
			push_error("Failed to connect to GameState.state_changed signal")
			return
	
	# Connect to level started for level transitions (check if already connected)
	if not game_state.level_started.is_connected(_on_level_started):
		var result = game_state.level_started.connect(_on_level_started)
		if result != OK:
			push_error("Failed to connect to GameState.level_started signal")
			return
	
	print("Background_Manager connected to GameState signals")

## Handle GameState state changes
func _on_game_state_changed(new_state: int) -> void:
	# Validate state value
	if new_state < 0 or new_state > 5:  # GameState.State enum has 6 values (0-5)
		push_warning("Invalid game state received: " + str(new_state))
		return
	
	# When returning to menu, load menu background
	if new_state == 0:  # GameState.State.MENU
		load_menu_background()
		print("Transition: Returning to menu background")

## Handle level start events
func _on_level_started(level_number: int) -> void:
	# Validate level number
	if level_number < 1 or level_number > 3:
		push_warning("Invalid level number received: " + str(level_number))
		return
	
	# Load the appropriate level background
	load_level_background(level_number)
	print("Transition: Loading level ", level_number, " background")

## Load configuration from backgrounds_config.json
func load_config() -> Dictionary:
	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				config_data = json.data
				_validate_and_fix_config()
				print("Background configuration loaded successfully")
				return config_data
			else:
				push_error("Failed to parse backgrounds_config.json at line " + str(json.get_error_line()) + ": " + json.get_error_message())
				push_error("Using hardcoded fallback configuration")
				_use_fallback_config()
		else:
			push_error("Failed to open backgrounds_config.json (file access error)")
			push_error("Using hardcoded fallback configuration")
			_use_fallback_config()
	else:
		push_warning("backgrounds_config.json not found at: " + CONFIG_PATH)
		push_warning("Using hardcoded fallback configuration")
		_use_fallback_config()
	
	return config_data

## Use hardcoded fallback configuration
func _use_fallback_config() -> void:
	config_data = {
		"defaults": {
			"opacity": 1.0,
			"darken_bright_backgrounds": true,
			"brightness_threshold": 0.6,
			"darken_amount": 0.3,
			"fallback_colors": {
				"level_1": "#8B4513",
				"level_2": "#4682B4",
				"level_3": "#9370DB"
			}
		},
		"backgrounds": {
			"level_1": {
				"path": "res://assets/backgrounds/level_1_bg.png",
				"type": "static",
				"opacity": 0.85
			},
			"level_2": {
				"path": "res://assets/backgrounds/level_2_bg.png",
				"type": "static",
				"opacity": 0.85
			},
			"level_3": {
				"path": "res://assets/backgrounds/level_3_bg.png",
				"type": "static",
				"opacity": 0.85
			},
			"menu": {
				"path": "res://assets/backgrounds/menu_bg",
				"type": "animated",
				"animation_speed": 1.0,
				"loop": true,
				"frame_count": 8
			}
		}
	}

## Validate and fix configuration, applying defaults for missing or invalid values
func _validate_and_fix_config() -> void:
	var fixed_count = 0
	
	# Ensure top-level keys exist
	if not config_data.has("defaults"):
		push_warning("Configuration missing 'defaults' key, using default values")
		config_data["defaults"] = {}
		fixed_count += 1
	
	if not config_data.has("backgrounds"):
		push_error("Configuration missing 'backgrounds' key, using fallback configuration")
		_use_fallback_config()
		return
	
	# Validate and fix defaults section
	var defaults = config_data["defaults"]
	
	if not defaults.has("opacity") or not _is_valid_opacity(defaults["opacity"]):
		if defaults.has("opacity"):
			push_warning("Invalid default opacity value: " + str(defaults["opacity"]) + ", using 1.0")
		else:
			push_warning("Missing default opacity, using 1.0")
		defaults["opacity"] = 1.0
		fixed_count += 1
	
	if not defaults.has("darken_bright_backgrounds"):
		push_warning("Missing darken_bright_backgrounds setting, using true")
		defaults["darken_bright_backgrounds"] = true
		fixed_count += 1
	
	if not defaults.has("brightness_threshold") or not _is_valid_float_range(defaults["brightness_threshold"], 0.0, 1.0):
		if defaults.has("brightness_threshold"):
			push_warning("Invalid brightness_threshold: " + str(defaults["brightness_threshold"]) + ", using 0.6")
		else:
			push_warning("Missing brightness_threshold, using 0.6")
		defaults["brightness_threshold"] = 0.6
		fixed_count += 1
	
	if not defaults.has("darken_amount") or not _is_valid_float_range(defaults["darken_amount"], 0.0, 1.0):
		if defaults.has("darken_amount"):
			push_warning("Invalid darken_amount: " + str(defaults["darken_amount"]) + ", using 0.3")
		else:
			push_warning("Missing darken_amount, using 0.3")
		defaults["darken_amount"] = 0.3
		fixed_count += 1
	
	if not defaults.has("fallback_colors"):
		push_warning("Missing fallback_colors, using default colors")
		defaults["fallback_colors"] = {
			"level_1": "#8B4513",
			"level_2": "#4682B4",
			"level_3": "#9370DB"
		}
		fixed_count += 1
	else:
		# Validate fallback colors
		var fallback_colors = defaults["fallback_colors"]
		if not fallback_colors.has("level_1"):
			push_warning("Missing fallback color for level_1, using #8B4513")
			fallback_colors["level_1"] = "#8B4513"
			fixed_count += 1
		if not fallback_colors.has("level_2"):
			push_warning("Missing fallback color for level_2, using #4682B4")
			fallback_colors["level_2"] = "#4682B4"
			fixed_count += 1
		if not fallback_colors.has("level_3"):
			push_warning("Missing fallback color for level_3, using #9370DB")
			fallback_colors["level_3"] = "#9370DB"
			fixed_count += 1
	
	# Validate and fix backgrounds section
	var backgrounds = config_data["backgrounds"]
	var required_backgrounds = ["level_1", "level_2", "level_3", "menu"]
	
	for bg_id in required_backgrounds:
		if not backgrounds.has(bg_id):
			push_error("Configuration missing required background: " + bg_id)
			# Add minimal valid configuration
			if bg_id == "menu":
				backgrounds[bg_id] = {
					"path": "res://assets/backgrounds/menu_bg",
					"type": "animated",
					"animation_speed": 1.0,
					"loop": true,
					"frame_count": 8
				}
			else:
				backgrounds[bg_id] = {
					"path": "res://assets/backgrounds/" + bg_id + "_bg.png",
					"type": "static",
					"opacity": 0.85
				}
			fixed_count += 1
			continue
		
		var bg_config = backgrounds[bg_id]
		
		# Validate path
		if not bg_config.has("path") or not bg_config["path"] is String or bg_config["path"].is_empty():
			push_error("Background " + bg_id + " missing or has invalid 'path', using default")
			if bg_id == "menu":
				bg_config["path"] = "res://assets/backgrounds/menu_bg"
			else:
				bg_config["path"] = "res://assets/backgrounds/" + bg_id + "_bg.png"
			fixed_count += 1
		
		# Validate type
		if not bg_config.has("type") or not bg_config["type"] is String:
			push_warning("Background " + bg_id + " missing or has invalid 'type', using 'static'")
			bg_config["type"] = "static"
			fixed_count += 1
		elif bg_config["type"] != "static" and bg_config["type"] != "animated" and bg_config["type"] != "shader":
			push_warning("Background " + bg_id + " has invalid type '" + str(bg_config["type"]) + "', using 'static'")
			bg_config["type"] = "static"
			fixed_count += 1
		
		# Validate opacity
		if not bg_config.has("opacity"):
			bg_config["opacity"] = defaults["opacity"]
		elif not _is_valid_opacity(bg_config["opacity"]):
			push_warning("Background " + bg_id + " has invalid opacity: " + str(bg_config["opacity"]) + ", using default")
			bg_config["opacity"] = defaults["opacity"]
			fixed_count += 1
		
		# Validate animated-specific fields
		if bg_config["type"] == "animated":
			if not bg_config.has("animation_speed") or not _is_valid_positive_float(bg_config["animation_speed"]):
				if bg_config.has("animation_speed"):
					push_warning("Background " + bg_id + " has invalid animation_speed: " + str(bg_config["animation_speed"]) + ", using 1.0")
				else:
					push_warning("Background " + bg_id + " missing animation_speed, using 1.0")
				bg_config["animation_speed"] = 1.0
				fixed_count += 1
			
			if not bg_config.has("loop"):
				push_warning("Background " + bg_id + " missing loop setting, using true")
				bg_config["loop"] = true
				fixed_count += 1
			elif not bg_config["loop"] is bool:
				push_warning("Background " + bg_id + " has invalid loop value: " + str(bg_config["loop"]) + ", using true")
				bg_config["loop"] = true
				fixed_count += 1
			
			if not bg_config.has("frame_count") or not _is_valid_positive_int(bg_config["frame_count"]):
				if bg_config.has("frame_count"):
					push_warning("Background " + bg_id + " has invalid frame_count: " + str(bg_config["frame_count"]) + ", using 8")
				else:
					push_warning("Background " + bg_id + " missing frame_count, using 8")
				bg_config["frame_count"] = 8
				fixed_count += 1
	
	if fixed_count > 0:
		print("Configuration validation complete: fixed " + str(fixed_count) + " issues")
	else:
		print("Configuration validation complete: no issues found")

## Validate if a value is a valid opacity (0.0 to 1.0)
func _is_valid_opacity(value) -> bool:
	return value is float or value is int and value >= 0.0 and value <= 1.0

## Validate if a value is a valid float in a range
func _is_valid_float_range(value, min_val: float, max_val: float) -> bool:
	return (value is float or value is int) and value >= min_val and value <= max_val

## Validate if a value is a positive float
func _is_valid_positive_float(value) -> bool:
	return (value is float or value is int) and value > 0.0

## Validate if a value is a positive integer (accepts both int and float that represents an integer)
func _is_valid_positive_int(value) -> bool:
	if value is int:
		return value > 0
	elif value is float:
		# Accept floats that are whole numbers (e.g., 8.0)
		return value > 0.0 and value == floor(value)
	return false

## Preload all background textures during initialization
func _preload_all_backgrounds() -> void:
	if not config_data.has("backgrounds"):
		push_warning("No backgrounds configuration found, skipping preload")
		return
	
	var backgrounds = config_data["backgrounds"]
	total_memory_usage = 0
	var preload_count = 0
	
	print("Preloading background textures...")
	
	for background_id in backgrounds.keys():
		# Skip metadata entries (start with underscore)
		if background_id.begins_with("_"):
			continue
		
		var bg_config = backgrounds[background_id]
		
		# Validate that bg_config is a Dictionary
		if not bg_config is Dictionary:
			push_warning("Invalid background configuration for: " + background_id + " (expected Dictionary, got " + str(typeof(bg_config)) + "), skipping preload")
			continue
		
		var bg_type = bg_config.get("type", "static")
		var bg_path = bg_config.get("path", "")
		
		if bg_path.is_empty():
			push_warning("Empty path for background: " + background_id + ", skipping preload")
			continue
		
		if bg_type == "static":
			# Preload static background texture
			if ResourceLoader.exists(bg_path):
				var texture = load(bg_path)
				if texture:
					preloaded_textures[background_id] = texture
					var memory_size = _estimate_texture_memory(texture)
					total_memory_usage += memory_size
					preload_count += 1
					print("  Preloaded: ", background_id, " (", _format_memory_size(memory_size), ")")
				else:
					push_warning("Failed to preload texture: " + bg_path)
			else:
				push_warning("Background asset not found: " + bg_path + ", skipping preload")
		
		elif bg_type == "animated":
			# Preload animated background frames
			var frame_count = bg_config.get("frame_count", 8)
			var frames_array = []
			var frames_memory = 0
			
			for i in range(frame_count):
				var frame_path = bg_path + "/frame_" + str(i) + ".png"
				if ResourceLoader.exists(frame_path):
					var texture = load(frame_path)
					if texture:
						frames_array.append(texture)
						var memory_size = _estimate_texture_memory(texture)
						frames_memory += memory_size
					else:
						push_warning("Failed to preload frame: " + frame_path)
				else:
					push_warning("Animation frame not found: " + frame_path)
			
			if frames_array.size() > 0:
				preloaded_textures[background_id] = frames_array
				total_memory_usage += frames_memory
				preload_count += 1
				print("  Preloaded: ", background_id, " (", frames_array.size(), " frames, ", _format_memory_size(frames_memory), ")")
			else:
				push_warning("No frames loaded for animated background: " + background_id)
	
	print("Background preload complete: ", preload_count, " backgrounds, total memory: ", _format_memory_size(total_memory_usage))
	
	# Check if memory usage exceeds target (50MB as per requirements)
	var max_memory_mb = 50 * 1024 * 1024  # 50MB in bytes
	if total_memory_usage > max_memory_mb:
		push_warning("Background memory usage (", _format_memory_size(total_memory_usage), ") exceeds target of 50MB")

## Estimate texture memory usage in bytes
func _estimate_texture_memory(texture: Texture2D) -> int:
	if not texture:
		return 0
	
	var size = texture.get_size()
	# Estimate: width * height * 4 bytes per pixel (RGBA)
	# This is a rough estimate; actual memory may vary with compression
	return int(size.x * size.y * 4)

## Format memory size for human-readable output
func _format_memory_size(bytes: int) -> String:
	if bytes < 1024:
		return str(bytes) + " B"
	elif bytes < 1024 * 1024:
		return str(bytes / 1024) + " KB"
	else:
		return "%.2f MB" % (float(bytes) / (1024.0 * 1024.0))

## Calculate average brightness of a texture (0.0 = black, 1.0 = white)
func _calculate_texture_brightness(texture: Texture2D) -> float:
	if not texture:
		return 0.0
	
	# Get texture image data
	var image = texture.get_image()
	if not image:
		return 0.0
	
	# Sample pixels to estimate brightness (sample every 10th pixel for performance)
	var total_brightness = 0.0
	var sample_count = 0
	var size = image.get_size()
	
	for y in range(0, int(size.y), 10):
		for x in range(0, int(size.x), 10):
			var pixel = image.get_pixel(x, y)
			# Calculate perceived brightness using luminance formula
			var brightness = (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114)
			total_brightness += brightness
			sample_count += 1
	
	if sample_count == 0:
		return 0.0
	
	return total_brightness / sample_count

## Apply darkening effect to a sprite node if background is bright
func _apply_brightness_adjustment(sprite_node: Node, texture: Texture2D) -> void:
	if not sprite_node or not texture:
		return
	
	# Get configuration for brightness adjustment
	var defaults = config_data.get("defaults", {})
	var should_darken = defaults.get("darken_bright_backgrounds", true)
	var brightness_threshold = defaults.get("brightness_threshold", 0.6)
	var darken_amount = defaults.get("darken_amount", 0.3)
	
	if not should_darken:
		return
	
	# Calculate texture brightness
	var brightness = _calculate_texture_brightness(texture)
	
	# If background is bright, apply darkening
	if brightness > brightness_threshold:
		var darken_factor = 1.0 - darken_amount
		sprite_node.modulate = sprite_node.modulate * Color(darken_factor, darken_factor, darken_factor, 1.0)
		print("Applied darkening to bright background (brightness: %.2f)" % brightness)

## Load a level background
func load_level_background(level_number: int) -> void:
	if level_number < 1 or level_number > 3:
		push_error("Invalid level number: " + str(level_number))
		return
	
	var background_id = "level_" + str(level_number)
	_load_background(background_id)

## Load the menu background
func load_menu_background() -> void:
	_load_background("menu")

## Internal method to load any background by ID
func _load_background(background_id: String) -> void:
	# Clean up previous background
	cleanup_current_background()
	
	# Get background configuration
	if not config_data.has("backgrounds"):
		push_error("No backgrounds configuration available (context: loading " + background_id + ")")
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	if not config_data["backgrounds"].has(background_id):
		push_error("Background configuration not found for: " + background_id + " (available: " + str(config_data["backgrounds"].keys()) + ")")
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	var bg_config = config_data["backgrounds"][background_id]
	var bg_path = bg_config.get("path", "")
	var bg_type = bg_config.get("type", "static")
	var bg_opacity = bg_config.get("opacity", 1.0)
	
	# Validate configuration values with context
	if bg_opacity < 0.0 or bg_opacity > 1.0:
		push_warning("Invalid opacity value for " + background_id + ": " + str(bg_opacity) + " (must be 0.0-1.0), using 1.0")
		bg_opacity = 1.0
	
	if bg_path.is_empty():
		push_error("Empty path for background: " + background_id + " (context: configuration validation should have caught this)")
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	# Create canvas layer for background with guaranteed z-ordering
	# Z-index -100 ensures backgrounds ALWAYS render behind:
	# - Game elements (default z-index: 0)
	# - UI elements (typical z-index: 100+)
	# This guarantee is validated by test_z_ordering.gd
	current_canvas_layer = CanvasLayer.new()
	current_canvas_layer.layer = -100
	get_tree().root.add_child(current_canvas_layer)
	
	# Load based on type
	if bg_type == "static":
		_load_static_background(background_id, bg_path, bg_opacity)
	elif bg_type == "animated":
		_load_animated_background(background_id, bg_config)
	elif bg_type == "shader":
		_load_shader_background(background_id, bg_config)
	else:
		push_error("Unknown background type for " + background_id + ": " + bg_type + " (expected 'static', 'animated', or 'shader')")
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)

## Load a static background image
func _load_static_background(background_id: String, path: String, opacity: float) -> void:
	var texture: Texture2D = null
	
	# Try to use preloaded texture first
	if preloaded_textures.has(background_id):
		texture = preloaded_textures[background_id]
		print("Using preloaded texture for: ", background_id)
	else:
		# Fall back to runtime loading if not preloaded
		if not ResourceLoader.exists(path):
			push_error("Background asset not found for " + background_id + " at path: " + path)
			_show_fallback_background(background_id)
			background_load_failed.emit(background_id)
			return
		
		texture = load(path)
		if not texture:
			push_error("Failed to load background texture for " + background_id + " from path: " + path + " (resource loading failed)")
			_show_fallback_background(background_id)
			background_load_failed.emit(background_id)
			return
	
	# Create sprite node
	var sprite = Sprite2D.new()
	sprite.texture = texture
	sprite.modulate.a = opacity
	
	# Apply brightness adjustment for bright backgrounds
	_apply_brightness_adjustment(sprite, texture)
	
	# Scale to fill viewport while maintaining aspect ratio
	_scale_to_viewport(sprite, texture)
	
	# Add to canvas layer
	current_canvas_layer.add_child(sprite)
	current_sprite_node = sprite
	current_background_id = background_id
	
	print("Loaded static background: ", background_id)
	background_loaded.emit(background_id)

## Load a shader-based animated background
func _load_shader_background(background_id: String, bg_config: Dictionary) -> void:
	var shader_path = bg_config.get("shader_path", "")
	var texture_path = bg_config.get("path", "")
	var opacity = bg_config.get("opacity", 1.0)
	var shader_params = bg_config.get("shader_params", {})
	
	# Validate shader path
	if shader_path.is_empty():
		push_error("No shader_path specified for shader background: " + background_id)
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	if not ResourceLoader.exists(shader_path):
		push_error("Shader not found for " + background_id + " at path: " + shader_path)
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	# Load shader
	var shader = load(shader_path)
	if not shader:
		push_error("Failed to load shader for " + background_id + " from path: " + shader_path)
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	# Create sprite node
	var sprite = Sprite2D.new()
	
	# Load base texture if provided
	var texture: Texture2D = null
	if not texture_path.is_empty():
		if preloaded_textures.has(background_id):
			texture = preloaded_textures[background_id]
			print("Using preloaded texture for shader background: ", background_id)
		elif ResourceLoader.exists(texture_path):
			texture = load(texture_path)
			if not texture:
				push_warning("Failed to load base texture for shader background: " + texture_path)
		else:
			push_warning("Base texture not found for shader background: " + texture_path)
	
	# If no texture, create a white texture as base
	if not texture:
		var image = Image.create(VIEWPORT_WIDTH, VIEWPORT_HEIGHT, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		texture = ImageTexture.create_from_image(image)
	
	sprite.texture = texture
	
	# Create and apply shader material
	var material = ShaderMaterial.new()
	material.shader = shader
	
	# Apply shader parameters from configuration
	for param_name in shader_params.keys():
		var param_value = shader_params[param_name]
		
		# Convert color strings to Color objects
		if param_value is String and param_value.begins_with("#"):
			param_value = Color(param_value)
		
		material.set_shader_parameter(param_name, param_value)
		print("  Set shader parameter: ", param_name, " = ", param_value)
	
	sprite.material = material
	sprite.modulate.a = opacity
	
	# Scale to fill viewport
	_scale_to_viewport(sprite, texture)
	
	# Add to canvas layer
	current_canvas_layer.add_child(sprite)
	current_sprite_node = sprite
	current_background_id = background_id
	
	print("Loaded shader background: ", background_id, " with shader: ", shader_path)
	background_loaded.emit(background_id)

## Load an animated background
func _load_animated_background(background_id: String, bg_config: Dictionary) -> void:
	var base_path = bg_config.get("path", "")
	var frame_count = int(bg_config.get("frame_count", 8))  # Convert to int
	var animation_speed = bg_config.get("animation_speed", 1.0)
	var loop = bg_config.get("loop", true)
	var opacity = bg_config.get("opacity", 1.0)
	
	# Validate configuration values with context
	if frame_count <= 0:
		push_warning("Invalid frame_count for " + background_id + ": " + str(frame_count) + " (must be > 0), using 8")
		frame_count = 8
	
	if animation_speed <= 0.0:
		push_warning("Invalid animation_speed for " + background_id + ": " + str(animation_speed) + " (must be > 0.0), using 1.0")
		animation_speed = 1.0
	
	if opacity < 0.0 or opacity > 1.0:
		push_warning("Invalid opacity value for " + background_id + ": " + str(opacity) + " (must be 0.0-1.0), using 1.0")
		opacity = 1.0
	
	# Create AnimatedSprite2D
	var animated_sprite = AnimatedSprite2D.new()
	
	# Create SpriteFrames resource
	var sprite_frames = SpriteFrames.new()
	sprite_frames.add_animation("default")
	
	var frames_loaded = 0
	var missing_frames = []
	
	# Try to use preloaded frames first
	if preloaded_textures.has(background_id) and preloaded_textures[background_id] is Array:
		var preloaded_frames = preloaded_textures[background_id]
		for texture in preloaded_frames:
			sprite_frames.add_frame("default", texture)
			frames_loaded += 1
		print("Using preloaded frames for: ", background_id, " (", frames_loaded, " frames)")
	else:
		# Fall back to runtime loading if not preloaded
		for i in range(frame_count):
			var frame_path = base_path + "/frame_" + str(i) + ".png"
			if ResourceLoader.exists(frame_path):
				var texture = load(frame_path)
				if texture:
					sprite_frames.add_frame("default", texture)
					frames_loaded += 1
				else:
					push_warning("Failed to load animation frame for " + background_id + ": " + frame_path + " (resource loading failed)")
					missing_frames.append(i)
			else:
				push_warning("Animation frame not found for " + background_id + ": " + frame_path)
				missing_frames.append(i)
	
	if frames_loaded == 0:
		push_error("No animation frames loaded for " + background_id + " (expected " + str(frame_count) + " frames at: " + base_path + "/frame_*.png)")
		_show_fallback_background(background_id)
		background_load_failed.emit(background_id)
		return
	
	if missing_frames.size() > 0:
		push_warning("Loaded partial animation for " + background_id + ": " + str(frames_loaded) + "/" + str(frame_count) + " frames (missing: " + str(missing_frames) + ")")
	
	# Configure animation
	sprite_frames.set_animation_loop("default", loop)
	sprite_frames.set_animation_speed("default", 5.0 * animation_speed)  # 5 FPS base speed
	
	animated_sprite.sprite_frames = sprite_frames
	animated_sprite.animation = "default"
	animated_sprite.modulate.a = opacity
	
	# Apply brightness adjustment for bright backgrounds (use first frame)
	if frames_loaded > 0:
		var first_texture = sprite_frames.get_frame_texture("default", 0)
		_apply_brightness_adjustment(animated_sprite, first_texture)
	
	# Scale to viewport (use first frame for size calculation)
	if frames_loaded > 0:
		var first_texture = sprite_frames.get_frame_texture("default", 0)
		_scale_to_viewport(animated_sprite, first_texture)
	
	# Add to canvas layer and start playing
	current_canvas_layer.add_child(animated_sprite)
	animated_sprite.play()
	current_sprite_node = animated_sprite
	current_background_id = background_id
	
	print("Loaded animated background: ", background_id, " (", frames_loaded, " frames)")
	background_loaded.emit(background_id)

## Scale sprite to fill viewport while maintaining aspect ratio
func _scale_to_viewport(sprite: Node2D, texture: Texture2D) -> void:
	if not texture:
		return
	
	var texture_size = texture.get_size()
	var scale_x = VIEWPORT_WIDTH / texture_size.x
	var scale_y = VIEWPORT_HEIGHT / texture_size.y
	
	# Use the larger scale to ensure viewport is filled
	var scale = max(scale_x, scale_y)
	sprite.scale = Vector2(scale, scale)
	
	# Center the sprite
	sprite.position = Vector2(VIEWPORT_WIDTH / 2.0, VIEWPORT_HEIGHT / 2.0)

## Show a solid color fallback background
func _show_fallback_background(background_id: String) -> void:
	var fallback_color = _get_fallback_color(background_id)
	
	# Create ColorRect as fallback
	var color_rect = ColorRect.new()
	color_rect.color = fallback_color
	color_rect.size = Vector2(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
	
	current_canvas_layer.add_child(color_rect)
	current_sprite_node = color_rect
	current_background_id = background_id
	
	print("Using fallback color for: ", background_id)

## Get fallback color for a background ID
func _get_fallback_color(background_id: String) -> Color:
	if config_data.has("defaults") and config_data["defaults"].has("fallback_colors"):
		var fallback_colors = config_data["defaults"]["fallback_colors"]
		if fallback_colors.has(background_id):
			return Color(fallback_colors[background_id])
	
	# Default fallback color
	return Color(0.2, 0.2, 0.2)

## Clean up current background
func cleanup_current_background() -> void:
	if current_canvas_layer:
		current_canvas_layer.queue_free()
		current_canvas_layer = null
	
	current_sprite_node = null
	current_background_id = ""

## Set background opacity
func set_background_opacity(opacity: float) -> void:
	if current_sprite_node and current_sprite_node.has("modulate"):
		current_sprite_node.modulate.a = clamp(opacity, 0.0, 1.0)

## Show a fallback background with a specific color (public API)
func show_fallback_background(color: Color) -> void:
	# Clean up previous background
	cleanup_current_background()
	
	# Create canvas layer for fallback background
	current_canvas_layer = CanvasLayer.new()
	current_canvas_layer.layer = -100
	
	# Create ColorRect as fallback
	var color_rect = ColorRect.new()
	color_rect.color = color
	color_rect.size = Vector2(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
	
	# Add to scene tree (use call_deferred if tree is busy)
	if get_tree() and get_tree().root:
		get_tree().root.call_deferred("add_child", current_canvas_layer)
		current_canvas_layer.call_deferred("add_child", color_rect)
	
	current_sprite_node = color_rect
	current_background_id = "fallback"
	
	print("Showing fallback background with color: ", color)

## Check if a background asset exists
func has_background_asset(background_id: String) -> bool:
	if not config_data.has("backgrounds") or not config_data["backgrounds"].has(background_id):
		return false
	
	var bg_config = config_data["backgrounds"][background_id]
	var bg_path = bg_config.get("path", "")
	
	return ResourceLoader.exists(bg_path)

## Get background path from configuration
func get_background_path(background_id: String) -> String:
	if config_data.has("backgrounds") and config_data["backgrounds"].has(background_id):
		return config_data["backgrounds"][background_id].get("path", "")
	return ""

## Get the current background ID
func get_current_background_id() -> String:
	return current_background_id

## Check if a background is currently loaded
func is_background_loaded() -> bool:
	return current_canvas_layer != null and current_sprite_node != null

## Get the current background type ("static", "animated", or "")
func get_current_background_type() -> String:
	if current_background_id.is_empty():
		return ""
	
	if config_data.has("backgrounds") and config_data["backgrounds"].has(current_background_id):
		return config_data["backgrounds"][current_background_id].get("type", "")
	
	return ""

## Get the current background opacity
func get_current_background_opacity() -> float:
	if current_sprite_node and current_sprite_node.has("modulate"):
		return current_sprite_node.modulate.a
	return 0.0

## Get background configuration for a specific background ID
func get_background_config(background_id: String) -> Dictionary:
	if config_data.has("backgrounds") and config_data["backgrounds"].has(background_id):
		return config_data["backgrounds"][background_id].duplicate()
	return {}

## Get all available background IDs
func get_available_backgrounds() -> Array:
	if config_data.has("backgrounds"):
		return config_data["backgrounds"].keys()
	return []

## Get default configuration values
func get_defaults() -> Dictionary:
	if config_data.has("defaults"):
		return config_data["defaults"].duplicate()
	return {}

## Get total memory usage of preloaded backgrounds in bytes
func get_memory_usage() -> int:
	return total_memory_usage

## Check if Background_Manager is initialized
func is_ready() -> bool:
	return is_initialized
