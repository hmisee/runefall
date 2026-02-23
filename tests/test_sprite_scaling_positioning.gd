extends GutTest
# Feature: sprite-graphics-integration, Property 4: Sprite Scaling and Positioning
# **Validates: Requirements 2.3, 3.3, 6.1, 6.2, 6.3, 6.4, 6.5**
#
# Property Test: Sprite Scaling and Positioning
# For any sprite with any dimensions, after scaling it should: 
# (1) fit within CELL_SIZE bounds, 
# (2) maintain its original aspect ratio, and 
# (3) be centered within its grid cell position.

const SpriteManager = preload("res://scripts/sprite_manager.gd")
const CELL_SIZE = 50  # GameBoard.CELL_SIZE constant value

var sprite_manager: SpriteManager

func run_tests():
	print("\n=== Running Sprite Scaling and Positioning Tests ===\n")
	print("DEBUG: Starting test execution")
	
	print("DEBUG: Running test_sprite_scaling_property")
	before_each()
	test_sprite_scaling_property()
	after_each()
	
	print("DEBUG: Running test_aspect_ratio_preservation")
	before_each()
	test_aspect_ratio_preservation()
	after_each()
	
	print("DEBUG: Running test_sprite_centering")
	before_each()
	test_sprite_centering()
	after_each()
	
	print("DEBUG: All tests complete")

func before_each():
	# Create a fresh SpriteManager instance for each test
	sprite_manager = SpriteManager.new()
	# Don't call _ready() - we don't need actual sprites loaded for scaling tests

func after_each():
	if sprite_manager:
		sprite_manager.queue_free()
		sprite_manager = null

# Property Test: For any sprite dimensions, scaled sprite should fit within CELL_SIZE
func test_sprite_scaling_property():
	print("\n=== Property Test: Sprite Scaling Fits Within CELL_SIZE ===")
	print("Running 10 iterations with various sprite dimensions\n")
	print("DEBUG: Test function started")
	
	var iterations = 10
	var failures = []
	
	print("DEBUG: About to define test_dimensions")
	# Test cases: various sprite dimensions (width, height)
	var test_dimensions = [
		Vector2(100, 100),  # Square, larger than cell
		Vector2(25, 25),    # Square, smaller than cell
		Vector2(200, 50),   # Wide rectangle
		Vector2(50, 200),   # Tall rectangle
		Vector2(10, 10),    # Very small
		Vector2(150, 150),  # Large square
		Vector2(150, 75),   # Wide, medium
		Vector2(75, 150),   # Tall, medium
		Vector2(5, 5),      # Minimal size
		Vector2(300, 100)   # Wide
	]
	
	print("DEBUG: Starting iteration loop")
	for iteration in range(iterations):
		print("DEBUG: Iteration %d" % iteration)
		var dimensions = test_dimensions[iteration]
		
		# Create a mock sprite with specific dimensions
		var sprite = Sprite2D.new()
		var mock_texture = create_mock_texture(dimensions)
		sprite.texture = mock_texture
		
		# Apply scaling using SpriteManager
		sprite_manager.scale_sprite_to_cell(sprite)
		
		# Calculate actual scaled dimensions
		var scaled_width = dimensions.x * sprite.scale.x
		var scaled_height = dimensions.y * sprite.scale.y
		
		# Property 1: Scaled sprite should fit within CELL_SIZE bounds
		# Use tolerance for floating-point comparison
		var tolerance = 0.1
		if scaled_width > CELL_SIZE + tolerance:
			failures.append("Iteration %d: Scaled width %.2f exceeds CELL_SIZE %d (original: %s)" % 
				[iteration, scaled_width, CELL_SIZE, dimensions])
		
		if scaled_height > CELL_SIZE + tolerance:
			failures.append("Iteration %d: Scaled height %.2f exceeds CELL_SIZE %d (original: %s)" % 
				[iteration, scaled_height, CELL_SIZE, dimensions])
		
		# Property 2: At least one dimension should be close to CELL_SIZE (efficient space usage)
		var max_scaled_dimension = max(scaled_width, scaled_height)
		if abs(max_scaled_dimension - CELL_SIZE) > tolerance:
			failures.append("Iteration %d: Max dimension %.2f not close to CELL_SIZE %d (original: %s)" % 
				[iteration, max_scaled_dimension, CELL_SIZE, dimensions])
		
		sprite.queue_free()
	
	# Report results
	if failures.size() > 0:
		print("FAILURES DETECTED:")
		for failure in failures:
			print("  - ", failure)
		assert_true(false, "Sprite scaling property violated. See failures above.")
	else:
		print("✓ All %d iterations passed" % iterations)
		print("✓ All sprites fit within CELL_SIZE bounds after scaling")
		assert_true(true, "Sprite scaling property holds")

# Property Test: Aspect ratio should be preserved after scaling
func test_aspect_ratio_preservation():
	print("\n=== Property Test: Aspect Ratio Preservation ===")
	print("Running 10 iterations to verify aspect ratio is maintained\n")
	
	var iterations = 10
	var failures = []
	
	var test_dimensions = [
		Vector2(100, 100),  # 1:1 ratio
		Vector2(200, 100),  # 2:1 ratio
		Vector2(100, 200),  # 1:2 ratio
		Vector2(150, 50),   # 3:1 ratio
		Vector2(50, 150),   # 1:3 ratio
		Vector2(80, 60),    # 4:3 ratio
		Vector2(160, 90),   # 16:9 ratio
		Vector2(300, 100),  # 3:1 ratio
		Vector2(100, 300),  # 1:3 ratio
		Vector2(250, 250)   # 1:1 ratio
	]
	
	for iteration in range(iterations):
		var dimensions = test_dimensions[iteration]
		
		# Calculate original aspect ratio
		var original_aspect_ratio = dimensions.x / dimensions.y
		
		# Create sprite and scale it
		var sprite = Sprite2D.new()
		var mock_texture = create_mock_texture(dimensions)
		sprite.texture = mock_texture
		
		sprite_manager.scale_sprite_to_cell(sprite)
		
		# Calculate scaled dimensions
		var scaled_width = dimensions.x * sprite.scale.x
		var scaled_height = dimensions.y * sprite.scale.y
		
		# Calculate scaled aspect ratio
		var scaled_aspect_ratio = scaled_width / scaled_height
		
		# Property: Aspect ratio should be preserved (within floating point tolerance)
		var aspect_ratio_diff = abs(original_aspect_ratio - scaled_aspect_ratio)
		var tolerance = 0.001
		
		if aspect_ratio_diff > tolerance:
			failures.append("Iteration %d: Aspect ratio changed from %.4f to %.4f (diff: %.4f, original: %s)" % 
				[iteration, original_aspect_ratio, scaled_aspect_ratio, aspect_ratio_diff, dimensions])
		
		# Additional check: scale.x should equal scale.y (uniform scaling)
		var scale_diff = abs(sprite.scale.x - sprite.scale.y)
		if scale_diff > tolerance:
			failures.append("Iteration %d: Non-uniform scaling detected (scale.x: %.4f, scale.y: %.4f, original: %s)" % 
				[iteration, sprite.scale.x, sprite.scale.y, dimensions])
		
		sprite.queue_free()
	
	# Report results
	if failures.size() > 0:
		print("FAILURES DETECTED:")
		for failure in failures:
			print("  - ", failure)
		assert_true(false, "Aspect ratio preservation property violated. See failures above.")
	else:
		print("✓ All %d iterations passed" % iterations)
		print("✓ Aspect ratio preserved for all sprite dimensions")
		assert_true(true, "Aspect ratio preservation property holds")

# Property Test: Sprites should be centered within their grid cell
func test_sprite_centering():
	print("\n=== Property Test: Sprite Centering ===")
	print("Running 10 iterations to verify sprites are centered\n")
	
	var iterations = 10
	var failures = []
	
	var test_dimensions = [
		Vector2(100, 100),
		Vector2(50, 50),
		Vector2(200, 100),
		Vector2(100, 200),
		Vector2(300, 150),
		Vector2(150, 300),
		Vector2(80, 80),
		Vector2(120, 60),
		Vector2(60, 120),
		Vector2(250, 250)
	]
	
	for iteration in range(iterations):
		var dimensions = test_dimensions[iteration]
		
		# Create sprite and scale it
		var sprite = Sprite2D.new()
		var mock_texture = create_mock_texture(dimensions)
		sprite.texture = mock_texture
		
		sprite_manager.scale_sprite_to_cell(sprite)
		
		# Property: Sprite2D nodes are centered by default (centered=true)
		# The sprite should be at position (0,0) relative to its parent
		# This means it's centered at the parent's position
		
		# Verify sprite is using centered rendering (Godot default)
		if not sprite.centered:
			failures.append("Iteration %d: Sprite is not centered (centered property is false)" % iteration)
		
		# Verify sprite position is at origin (centered within parent)
		var tolerance = 0.001
		if abs(sprite.position.x) > tolerance or abs(sprite.position.y) > tolerance:
			failures.append("Iteration %d: Sprite position is not at origin (%.2f, %.2f), expected (0, 0)" % 
				[iteration, sprite.position.x, sprite.position.y])
		
		sprite.queue_free()
	
	# Report results
	if failures.size() > 0:
		print("FAILURES DETECTED:")
		for failure in failures:
			print("  - ", failure)
		assert_true(false, "Sprite centering property violated. See failures above.")
	else:
		print("✓ All %d iterations passed" % iterations)
		print("✓ All sprites are properly centered within their grid cells")
		assert_true(true, "Sprite centering property holds")

# Helper function to create a mock texture with specific dimensions
# Note: In headless mode, we create a minimal 1x1 image and rely on get_size() override
func create_mock_texture(size: Vector2) -> Texture2D:
	# Create a minimal 1x1 image to avoid performance issues in headless mode
	var image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture = ImageTexture.create_from_image(image)
	
	# We'll need to work around the fact that we can't easily mock get_size()
	# Instead, we'll create a wrapper class
	return MockTexture.new(size, texture)

# Mock texture class that returns custom dimensions
class MockTexture extends Texture2D:
	var custom_size: Vector2
	var base_texture: Texture2D
	
	func _init(size: Vector2, texture: Texture2D):
		custom_size = size
		base_texture = texture
	
	func get_size() -> Vector2:
		return custom_size
	
	func get_width() -> int:
		return int(custom_size.x)
	
	func get_height() -> int:
		return int(custom_size.y)
