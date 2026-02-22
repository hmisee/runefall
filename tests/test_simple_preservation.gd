extends GutTest
# Simplified Preservation Tests - Minimal version to avoid timeouts

const GameBoard = preload("res://scripts/game_board.gd")
const Rune = preload("res://scripts/rune.gd")

var game_board: GameBoard

func run_tests():
	print("\n=== SIMPLE PRESERVATION TESTS ===\n")
	
	print("--- Test 1: Preview generation ---")
	test_preview_generation()
	
	print("\n--- Test 2: Gravity application ---")
	test_gravity_simple()
	
	print("\n=== Tests Complete ===")

func test_preview_generation():
	print("Testing preview generation")
	game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var preview = game_board.generate_next_pair_data()
	
	assert_true(preview.has("rune1_type"), "Preview has rune1_type")
	assert_true(preview.has("rune2_type"), "Preview has rune2_type")
	assert_true(preview.has("rotation"), "Preview has rotation")
	assert_true(preview["rune1_type"] >= 0 and preview["rune1_type"] <= 3, "rune1_type valid")
	assert_true(preview["rune2_type"] >= 0 and preview["rune2_type"] <= 3, "rune2_type valid")
	
	print("✓ Preview generation works correctly")
	
	game_board.queue_free()

func test_gravity_simple():
	print("Testing gravity application")
	game_board = GameBoard.new()
	game_board.initialize_grid()
	
	# Place a rune with space below
	var rune = Rune.new()
	rune.rune_type = 0
	rune.grid_x = 3
	rune.grid_y = 5
	game_board.add_child(rune)
	game_board.grid[5][3] = rune
	game_board.grid[6][3] = null
	
	# Apply gravity
	var fell = game_board.apply_gravity_once()
	
	assert_true(fell, "Rune should fall")
	assert_eq(rune.grid_y, 6, "Rune at correct position")
	
	print("✓ Gravity works correctly")
	
	game_board.queue_free()
