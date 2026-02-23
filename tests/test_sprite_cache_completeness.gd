extends GutTest
# Feature: sprite-graphics-integration, Property 1: Sprite cache has exactly 2 variants per type
# **Validates: Requirements 1.2**
#
# Property Test: Sprite Cache Completeness
# For any element type in the game (Fire, Water, Earth, Air), the SpriteManager sprite cache 
# should contain exactly two sprite entries: one for the rune variant and one for the element variant.

const SpriteManager = preload("res://scripts/sprite_manager.gd")

var sprite_manager: SpriteManager

func run_tests():
	print("\n=== Running Sprite Cache Completeness Tests ===\n")
	
	before_each()
	test_sprite_cache_completeness_property()
	after_each()
	
	before_each()
	test_sprite_cache_structure()
	after_each()
	
	before_each()
	test_sprite_cache_entry_types()
	after_each()

func before_each():
	# Create a fresh SpriteManager instance for each test
	sprite_manager = SpriteManager.new()
	# Trigger sprite loading
	sprite_manager._ready()

func after_each():
	if sprite_manager:
		sprite_manager.queue_free()
		sprite_manager = null

# Property Test: For any element type (0-3), sprite_cache should have exactly 2 entries
func test_sprite_cache_completeness_property():
	print("\n=== Property Test: Sprite Cache Completeness ===")
	print("Running 10 iterations to verify sprite cache structure\n")
	
	var iterations = 10
	var element_types = [0, 1, 2, 3]  # Fire, Water, Earth, Air
	var piece_types = ["rune", "element"]
	var failures = []
	
	for iteration in range(iterations):
		# Test each element type
		for element_type in element_types:
			# Property: sprite_cache should have an entry for this element type
			if not sprite_manager.sprite_cache.has(element_type):
				failures.append("Iteration %d: sprite_cache missing element_type %d" % [iteration, element_type])
				continue
			
			var type_cache = sprite_manager.sprite_cache[element_type]
			
			# Property: Each element type should have exactly 2 entries (rune and element)
			var entry_count = type_cache.keys().size()
			if entry_count != 2:
				failures.append("Iteration %d: element_type %d has %d entries, expected 2" % [iteration, element_type, entry_count])
			
			# Property: Both "rune" and "element" keys should exist
			for piece_type in piece_types:
				if not type_cache.has(piece_type):
					failures.append("Iteration %d: element_type %d missing '%s' variant" % [iteration, element_type, piece_type])
	
	# Report results
	if failures.size() > 0:
		print("FAILURES DETECTED:")
		for failure in failures:
			print("  - ", failure)
		assert_true(false, "Sprite cache completeness property violated. See failures above.")
	else:
		print("✓ All %d iterations passed" % iterations)
		print("✓ All element types (0-3) have exactly 2 sprite variants (rune, element)")
		assert_true(true, "Sprite cache completeness property holds")

# Additional test: Verify sprite cache structure after initialization
func test_sprite_cache_structure():
	print("\n=== Test: Sprite Cache Structure ===")
	
	# Verify sprite_cache is a Dictionary
	assert_true(sprite_manager.sprite_cache is Dictionary, "sprite_cache should be a Dictionary")
	
	# Verify all 4 element types are present
	for element_type in [0, 1, 2, 3]:
		assert_true(sprite_manager.sprite_cache.has(element_type), 
			"sprite_cache should have element_type %d" % element_type)
		
		var type_cache = sprite_manager.sprite_cache[element_type]
		assert_true(type_cache is Dictionary, 
			"sprite_cache[%d] should be a Dictionary" % element_type)
		
		# Verify both piece types are present
		assert_true(type_cache.has("rune"), 
			"sprite_cache[%d] should have 'rune' key" % element_type)
		assert_true(type_cache.has("element"), 
			"sprite_cache[%d] should have 'element' key" % element_type)
		
		# Verify exactly 2 entries
		assert_eq(type_cache.keys().size(), 2, 
			"sprite_cache[%d] should have exactly 2 entries" % element_type)
	
	print("✓ Sprite cache structure is correct")

# Test: Verify sprite cache entries are either Texture2D or null
func test_sprite_cache_entry_types():
	print("\n=== Test: Sprite Cache Entry Types ===")
	
	for element_type in [0, 1, 2, 3]:
		var type_cache = sprite_manager.sprite_cache[element_type]
		
		for piece_type in ["rune", "element"]:
			var entry = type_cache[piece_type]
			
			# Entry should be either Texture2D (sprite loaded) or null (sprite missing)
			var is_valid = (entry == null) or (entry is Texture2D)
			assert_true(is_valid, 
				"sprite_cache[%d]['%s'] should be Texture2D or null, got %s" % 
				[element_type, piece_type, typeof(entry)])
			
			if entry == null:
				print("  Note: sprite_cache[%d]['%s'] is null (sprite file missing)" % 
					[element_type, piece_type])
	
	print("✓ All sprite cache entries have valid types")
