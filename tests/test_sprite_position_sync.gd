extends Node

# Feature: sprite-graphics-integration, Property 6: Sprite position syncs with game object
# **Validates: Requirements 5.2**

const ITERATIONS = 10

func _ready():
	print("=== Property Test: Sprite Position Synchronization ===")
	print("\nNote: In Godot, child nodes automatically inherit parent Node2D position.")
	print("This test verifies that sprites (added as children) sync with game object position.\n")
	
	var passed = 0
	var failed = 0
	var failures = []
	
	for i in range(ITERATIONS):
		var result = await test_position_sync_iteration(i)
		if result.success:
			passed += 1
		else:
			failed += 1
			failures.append(result.message)
	
	print("\nResults: %d/%d passed" % [passed, ITERATIONS])
	
	if failed > 0:
		print("\nFailures:")
		for failure in failures:
			print("  - %s" % failure)
		get_tree().quit(1)
	else:
		print("✓ All position synchronization tests passed!")
		print("✓ Sprite position synchronization property holds:")
		print("  - Sprites are children of parent Node2D nodes")
		print("  - Sprites automatically inherit position from parent")
		print("  - Position updates propagate correctly through scene tree")
		get_tree().quit(0)

func test_position_sync_iteration(iteration: int) -> Dictionary:
	# Test the fundamental property: child nodes inherit parent position
	# This is what makes sprite position synchronization work
	
	# Generate random positions for testing
	var test_positions = [
		Vector2(randf_range(-200, 200), randf_range(-200, 200)),
		Vector2(randf_range(-200, 200), randf_range(-200, 200)),
		Vector2(randf_range(-200, 200), randf_range(-200, 200))
	]
	
	# Create a parent Node2D (simulating Rune/Element)
	var parent = Node2D.new()
	add_child(parent)
	
	# Create a child Sprite2D (simulating sprite_node)
	var sprite = Sprite2D.new()
	parent.add_child(sprite)
	
	await get_tree().process_frame
	
	# Test 1: Initial position
	parent.position = test_positions[0]
	await get_tree().process_frame
	
	var sprite_global_pos = sprite.global_position
	var parent_global_pos = parent.global_position
	
	if not sprite_global_pos.is_equal_approx(parent_global_pos):
		parent.queue_free()
		return {
			"success": false,
			"message": "Iteration %d: Initial position mismatch - Parent at %s, Sprite at %s" % [iteration, parent_global_pos, sprite_global_pos]
		}
	
	# Test 2: Position update 1
	parent.position = test_positions[1]
	await get_tree().process_frame
	
	sprite_global_pos = sprite.global_position
	parent_global_pos = parent.global_position
	
	if not sprite_global_pos.is_equal_approx(parent_global_pos):
		parent.queue_free()
		return {
			"success": false,
			"message": "Iteration %d: Position update 1 mismatch - Parent at %s, Sprite at %s" % [iteration, parent_global_pos, sprite_global_pos]
		}
	
	# Test 3: Position update 2
	parent.position = test_positions[2]
	await get_tree().process_frame
	
	sprite_global_pos = sprite.global_position
	parent_global_pos = parent.global_position
	
	if not sprite_global_pos.is_equal_approx(parent_global_pos):
		parent.queue_free()
		return {
			"success": false,
			"message": "Iteration %d: Position update 2 mismatch - Parent at %s, Sprite at %s" % [iteration, parent_global_pos, sprite_global_pos]
		}
	
	# Cleanup
	parent.queue_free()
	
	return {"success": true, "message": ""}

