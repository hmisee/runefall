extends Node

# Simple test script to verify SpriteManager autoload is accessible
# This can be attached to any node to test the singleton

func _ready() -> void:
	print("Testing SpriteManager autoload accessibility...")
	
	# Test 1: Check if SpriteManager is accessible
	if SpriteManager:
		print("✓ SpriteManager singleton is accessible")
	else:
		push_error("✗ SpriteManager singleton is NOT accessible")
		return
	
	# Test 2: Check if sprite_cache exists
	if SpriteManager.sprite_cache != null:
		print("✓ SpriteManager.sprite_cache is accessible")
	else:
		push_error("✗ SpriteManager.sprite_cache is NOT accessible")
		return
	
	# Test 3: Check if methods are callable
	var test_sprite = SpriteManager.get_sprite(0, "rune")
	print("✓ SpriteManager.get_sprite() is callable")
	
	var has_test = SpriteManager.has_sprite(0, "rune")
	print("✓ SpriteManager.has_sprite() is callable")
	
	var missing = SpriteManager.get_missing_sprites()
	print("✓ SpriteManager.get_missing_sprites() is callable")
	
	# Test 4: Report missing sprites (expected since we don't have sprite assets yet)
	if missing.size() > 0:
		print("Note: %d sprites are missing (expected until assets are added)" % missing.size())
	
	print("All autoload tests passed!")
