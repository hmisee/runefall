extends SceneTree

# Script to generate placeholder background images
# Run with: godot --headless -s tools/generate_placeholder_backgrounds.gd

func _init():
	print("Generating placeholder backgrounds...")
	
	# Create level backgrounds with fallback colors
	create_placeholder("res://assets/backgrounds/level_1_bg.png", Color("#8B4513"))  # Warm brown
	create_placeholder("res://assets/backgrounds/level_2_bg.png", Color("#4682B4"))  # Steel blue
	create_placeholder("res://assets/backgrounds/level_3_bg.png", Color("#9370DB"))  # Medium purple
	
	# Create menu background frames (8 frames with slight color variations)
	var base_color = Color("#4B0082")  # Indigo base
	for i in range(8):
		var brightness = 0.8 + (sin(i * PI / 4.0) * 0.2)  # Oscillate brightness
		var frame_color = base_color * brightness
		create_placeholder("res://assets/backgrounds/menu_bg/frame_%d.png" % i, frame_color)
	
	print("Placeholder backgrounds generated successfully!")
	quit()

func create_placeholder(path: String, color: Color) -> void:
	# Create 600x900 image (viewport size)
	var img = Image.create(600, 900, false, Image.FORMAT_RGBA8)
	img.fill(color)
	
	# Save as PNG
	var err = img.save_png(path)
	if err == OK:
		print("Created: ", path)
	else:
		print("ERROR creating ", path, ": ", err)
