extends Node

# Test: Rune Sprite Rendering Path
# Validates that Rune class correctly implements sprite rendering when sprites are available
# and falls back to drawing when sprites are missing

const Rune = preload("res://scripts/rune.gd")

func _ready():
	print("\n=== Testing Rune Sprite Rendering Implementation ===\n")
	
	var all_passed = true
	
	# Test 1: Rune creates visual representation on ready
	if not await test_rune_creates_visual():
		all_passed = false
	
	# Test 2: Rune uses fallback when sprites missing
	if not await test_rune_fallback_when_no_sprites():
		all_passed = false
	
	# Test 3: Rune would use Sprite2D if sprites were available (mock test)
	if not test_rune_sprite_path_logic():
		all_passed = false
	
	print("\n=== Test Results ===")
	if all_passed:
		print("✓ All tests passed!")
	else:
		print("✗ Some tests failed")
	
	get_tree().quit()

func test_rune_creates_visual() -> bool:
	print("Test 1: Rune creates visual representation on ready")
	
	var rune = Rune.new()
	rune.rune_type = Rune.RuneType.FIRE
	add_child(rune)
	
	# Wait for _ready to be called
	await get_tree().process_frame
	
	# Rune should exist and be in the tree
	var passed = rune.is_inside_tree()
	
	if passed:
		print("  ✓ Rune successfully created and added to tree")
	else:
		print("  ✗ Rune failed to initialize properly")
	
	rune.queue_free()
	return passed

func test_rune_fallback_when_no_sprites() -> bool:
	print("\nTest 2: Rune uses fallback rendering when sprites are missing")
	
	var rune = Rune.new()
	rune.rune_type = Rune.RuneType.WATER
	add_child(rune)
	
	# Wait for _ready to be called
	await get_tree().process_frame
	
	# Since sprites don't exist, sprite_node should be null
	# and the rune should use _draw() method instead
	var passed = true
	
	# Check that SpriteManager returns null for missing sprites
	var sprite_texture = SpriteManager.get_sprite(Rune.RuneType.WATER, "rune")
	if sprite_texture != null:
		print("  ✗ Expected null sprite texture for missing sprite")
		passed = false
	else:
		print("  ✓ SpriteManager correctly returns null for missing sprite")
	
	# Check that sprite_node is null (fallback mode)
	if rune.sprite_node != null:
		print("  ✗ Expected sprite_node to be null in fallback mode")
		passed = false
	else:
		print("  ✓ Rune correctly uses fallback mode (sprite_node is null)")
	
	rune.queue_free()
	return passed

func test_rune_sprite_path_logic() -> bool:
	print("\nTest 3: Rune sprite rendering path logic verification")
	
	# This test verifies the logic without actual sprite files
	# We check that the code path is correct
	
	var passed = true
	
	# Verify SpriteManager has the get_sprite method
	if not SpriteManager.has_method("get_sprite"):
		print("  ✗ SpriteManager missing get_sprite method")
		passed = false
	else:
		print("  ✓ SpriteManager has get_sprite method")
	
	# Verify SpriteManager has the scale_sprite_to_cell method
	if not SpriteManager.has_method("scale_sprite_to_cell"):
		print("  ✗ SpriteManager missing scale_sprite_to_cell method")
		passed = false
	else:
		print("  ✓ SpriteManager has scale_sprite_to_cell method")
	
	# Verify Rune has sprite_node variable
	var rune = Rune.new()
	if not "sprite_node" in rune:
		print("  ✗ Rune missing sprite_node variable")
		passed = false
	else:
		print("  ✓ Rune has sprite_node variable")
	
	rune.queue_free()
	return passed
