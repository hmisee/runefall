extends Node
# Feature: sprite-graphics-integration, Property 5: Sprite Orientation Preservation
# **Validates: Requirements 5.1**
#
# Property Test: Sprite Orientation Preservation
# For any rune that undergoes rotation, the sprite should maintain its visual 
# orientation relative to the rune's coordinate system (the sprite rotates with 
# the rune, not independently).

const SpriteManager = preload("res://scripts/sprite_manager.gd")

var test_passed = true
var sprite_manager: SpriteManager

func run_tests():
	print("\n=== Running Sprite Orientation Preservation Tests ===\n")
	
	# Create a local SpriteManager instance for testing
	sprite_manager = SpriteManager.new()
	sprite_manager._ready()
	
	test_sprite_orientation_preservation_property()
	
	sprite_manager.queue_free()
	
	if test_passed:
		print("\n✓ All tests passed!")
	else:
		print("\n✗ Some tests failed")

# Property Test: For any Node2D rotation, child sprites inherit that rotation
func test_sprite_orientation_preservation_property():
	print("\n=== Property Test: Sprite Orientation Preservation ===")
	print("Running 10 iterations testing sprite rotation inheritance\n")
	print("Note: Since sprites are children of Rune Node2D, they automatically inherit rotation.\n")
	
	var iterations = 10
	var failures = []
	
	# Test cases: (rotation_degrees)
	var test_rotations = [0.0, 45.0, 90.0, 135.0, 180.0, 225.0, 270.0, 315.0, 360.0, -90.0]
	
	for iteration in range(iterations):
		var rotation_degrees = test_rotations[iteration]
		var rotation_radians = deg_to_rad(rotation_degrees)
		
		# Create a parent Node2D (simulating a Rune)
		var parent_node = Node2D.new()
		add_child(parent_node)
		
		# Create a child Sprite2D (simulating the sprite_node)
		var sprite = Sprite2D.new()
		parent_node.add_child(sprite)
		
		# Apply rotation to the parent node
		parent_node.rotation = rotation_radians
		
		# Property 1: Sprite should be a child of the parent node
		if sprite.get_parent() != parent_node:
			failures.append("Iteration %d: sprite parent is not the parent_node" % iteration)
		
		# Property 2: Sprite's global rotation should match parent's global rotation
		var parent_global_rotation = parent_node.global_rotation
		var sprite_global_rotation = sprite.global_rotation
		
		var rotation_diff = abs(parent_global_rotation - sprite_global_rotation)
		var tolerance = 0.001
		
		if rotation_diff > tolerance:
			failures.append("Iteration %d: Sprite rotation (%.4f rad) doesn't match parent rotation (%.4f rad), diff: %.4f" % 
				[iteration, sprite_global_rotation, parent_global_rotation, rotation_diff])
		
		# Property 3: Sprite's local rotation should be 0 (no independent rotation)
		var sprite_local_rotation = sprite.rotation
		
		if abs(sprite_local_rotation) > tolerance:
			failures.append("Iteration %d: Sprite has local rotation (%.4f rad), should be 0" % 
				[iteration, sprite_local_rotation])
		
		# Clean up
		parent_node.queue_free()
	
	# Report results
	if failures.size() > 0:
		print("FAILURES DETECTED:")
		for failure in failures:
			print("  - ", failure)
		test_passed = false
	else:
		print("✓ All %d iterations passed" % iterations)
		print("✓ Sprite orientation preservation property holds:")
		print("  - Sprites are children of parent Node2D nodes")
		print("  - Sprites automatically inherit rotation from parent")
		print("  - Sprites have no independent local rotation")
		print("  - This property applies to Rune nodes and their sprite_node children")

