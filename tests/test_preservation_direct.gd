extends SceneTree
# Direct preservation tests without GUT framework

const GameBoard = preload("res://scripts/game_board.gd")
const Rune = preload("res://scripts/rune.gd")

func _init():
	print("\n=== PRESERVATION PROPERTY TESTS ===")
	print("Testing normal gameplay mechanics (not calling initialize_level)\n")
	
	test_preview_generation()
	test_gravity_application()
	test_pair_spawning()
	
	print("\n=== All Preservation Tests Passed ===")
	quit()

func test_preview_generation():
	print("Test 1: Preview generation during gameplay")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var preview1 = game_board.generate_next_pair_data()
	var preview2 = game_board.generate_next_pair_data()
	
	assert(preview1.has("rune1_type"), "Preview should have rune1_type")
	assert(preview1.has("rune2_type"), "Preview should have rune2_type")
	assert(preview1.has("rotation"), "Preview should have rotation")
	assert(preview1["rune1_type"] >= 0 and preview1["rune1_type"] <= 3, "rune1_type should be 0-3")
	assert(preview1["rune2_type"] >= 0 and preview1["rune2_type"] <= 3, "rune2_type should be 0-3")
	assert(preview1["rotation"] == 0, "rotation should be 0")
	
	print("  ✓ Preview generation produces valid data structures")
	game_board.queue_free()

func test_gravity_application():
	print("Test 2: Gravity application works correctly")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	# Place a rune with empty space below
	var test_rune = Rune.new()
	test_rune.rune_type = 1
	test_rune.grid_x = 3
	test_rune.grid_y = 5
	test_rune.position = game_board.grid_to_world(3, 5)
	game_board.add_child(test_rune)
	game_board.grid[5][3] = test_rune
	game_board.grid[6][3] = null
	
	# Apply gravity once
	var pieces_fell = game_board.apply_gravity_once()
	
	assert(pieces_fell == true, "Rune should fall when space below is empty")
	assert(test_rune.grid_y == 6, "Rune should be at y=6 after falling")
	assert(game_board.grid[5][3] == null, "Original position should be empty")
	assert(game_board.grid[6][3] == test_rune, "New position should contain the rune")
	
	print("  ✓ Gravity correctly moves runes downward")
	game_board.queue_free()

func test_pair_spawning():
	print("Test 3: Pair spawning uses preview data correctly")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	game_board.game_active = true
	
	# Set up specific preview data
	game_board.next_rune_pair_data = {
		"rune1_type": 2,
		"rune2_type": 3,
		"rotation": 0
	}
	
	# Spawn a new pair
	game_board.spawn_new_pair()
	
	var spawned_pair = game_board.current_pair
	assert(spawned_pair != null, "A pair should be spawned")
	assert(spawned_pair.use_preview_data == true, "Pair should use preview data")
	assert(spawned_pair.preview_rune1_type == 2, "Preview rune1 should be Earth")
	assert(spawned_pair.preview_rune2_type == 3, "Preview rune2 should be Air")
	
	print("  ✓ Pair spawning correctly uses preview data")
	game_board.queue_free()
