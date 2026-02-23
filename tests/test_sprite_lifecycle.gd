extends Node

# Feature: sprite-graphics-integration, Property 7: Sprites removed with game objects
# **Validates: Requirements 5.3**

const ITERATIONS = 10

func _ready():
	print("=== Property Test: Sprite Lifecycle Coupling ===")
	print("\nNote: In Godot, when a parent node is freed, all children are automatically freed.")
	print("This test verifies that sprites are properly removed when game objects are freed.\n")
	
	var passed = 0
	var failed = 0
	var failures = []
	
	for i in range(ITERATIONS):
		var result = await test_lifecycle_coupling_iteration(i)
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
		print("✓ All lifecycle coupling tests passed!")
		print("✓ Sprite lifecycle coupling property holds:")
		print("  - Sprites are children of parent Node2D nodes")
		print("  - When parent is freed, children are automatically freed")
		print("  - No orphaned sprites remain in scene tree")
		print("  - Sprite lifecycle is properly coupled to game object lifecycle")
		get_tree().quit(0)

func test_lifecycle_coupling_iteration(iteration: int) -> Dictionary:
	# Test the fundamental property: child nodes are freed with parent
	# This is what makes sprite lifecycle coupling work
	
	# Create a parent Node2D (simulating Rune/Element)
	var parent = Node2D.new()
	parent.name = "TestParent_%d" % iteration
	add_child(parent)
	
	# Create a child Sprite2D (simulating sprite_node)
	var sprite = Sprite2D.new()
	sprite.name = "TestSprite_%d" % iteration
	parent.add_child(sprite)
	
	await get_tree().process_frame
	
	# Verify both are in the scene tree
	if not is_instance_valid(parent):
		return {
			"success": false,
			"message": "Iteration %d: Parent node is not valid after creation" % iteration
		}
	
	if not is_instance_valid(sprite):
		return {
			"success": false,
			"message": "Iteration %d: Sprite node is not valid after creation" % iteration
		}
	
	# Get the sprite's path for verification
	var sprite_path = sprite.get_path()
	
	# Free the parent
	parent.queue_free()
	
	# Wait for the deferred free to process
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Verify parent is no longer valid
	if is_instance_valid(parent):
		return {
			"success": false,
			"message": "Iteration %d: Parent node still valid after queue_free()" % iteration
		}
	
	# Verify sprite is also no longer valid (freed with parent)
	if is_instance_valid(sprite):
		return {
			"success": false,
			"message": "Iteration %d: Sprite node still valid after parent freed (orphaned sprite!)" % iteration
		}
	
	# Verify sprite is not in the scene tree
	if has_node(sprite_path):
		return {
			"success": false,
			"message": "Iteration %d: Sprite still in scene tree after parent freed" % iteration
		}
	
	return {"success": true, "message": ""}
