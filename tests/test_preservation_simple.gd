extends GutTest
# Simplified Preservation Property Tests for Rune Rotation Fix
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
#
# These tests verify that non-rotation behavior remains unchanged
# Expected to PASS on UNFIXED code (baseline behavior)

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")
const Rune = preload("res://scripts/rune.gd")
const Element = preload("res://scripts/element.gd")

var game_board: GameBoard

func setup_game_board():
	game_board = GameBoard.new()
	game_board.initialize_grid()

func cleanup_game_board():
	if game_board:
		game_board.queue_free()
		game_board = null

func run_tests():
	print("\n=== PRESERVATION PROPERTY TESTS (Simplified) ===\n")
	
	print("--- Test 1: Horizontal Movement ---")
	setup_game_board()
	test_horizontal_movement()
	cleanup_game_board()
	
	print("\n--- Test 2: Vertical Movement ---")
	setup_game_board()
	test_vertical_movement()
	cleanup_game_board()
	
	print("\n--- Test 3: Collision Detection ---")
	setup_game_board()
	test_collision_detection()
	cleanup_game_board()
	
	print("\n--- Test 4: Pair Positions ---")
	setup_game_board()
	test_pair_positions()
	cleanup_game_board()

# Test horizontal movement with collision checking
func test_horizontal_movement():
	var pair = create_pair_at(3, 5, true)
	
	# Move right in open space
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 4, "Should move right")
	print("✓ Move right: (3,5) -> (4,5)")
	
	# Move left in open space
	game_board.move_pair_horizontal(-1)
	assert_eq(pair.grid_x, 3, "Should move left")
	print("✓ Move left: (4,5) -> (3,5)")
	
	# Cannot move left at edge
	pair.grid_x = 0
	game_board.move_pair_horizontal(-1)
	assert_eq(pair.grid_x, 0, "Should not move past left edge")
	print("✓ Blocked at left edge")
	
	# Horizontal pair cannot move to x=7
	pair.grid_x = 6
	pair.is_horizontal = true
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 6, "Horizontal pair blocked at right edge")
	print("✓ Horizontal pair blocked at right edge")
	
	# Vertical pair can move to x=7
	pair.is_horizontal = false
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 7, "Vertical pair can reach x=7")
	print("✓ Vertical pair can reach x=7")
	
	print("Horizontal movement: PASSED")

# Test vertical movement
func test_vertical_movement():
	var pair = create_pair_at(3, 5, true)
	
	# Move down in open space
	var initial_y = pair.grid_y
	game_board.move_pair_down()
	assert_eq(pair.grid_y, initial_y + 1, "Should move down")
	print("✓ Move down: (3,5) -> (3,6)")
	
	print("Vertical movement: PASSED")

# Test collision detection
func test_collision_detection():
	var pair = create_pair_at(2, 5, true)
	place_element_at(4, 5)
	
	# Try to move right - blocked by element
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 2, "Should not move through element")
	print("✓ Horizontal movement blocked by collision")
	
	# Test vertical collision
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, false)  # Vertical
	place_element_at(3, 7)
	
	# Try to move down - should be blocked because rune2 would be at (3,7)
	game_board.move_pair_down()
	assert_eq(pair.grid_y, 5, "Vertical pair should not move into collision")
	print("✓ Vertical pair blocked by collision")
	
	print("Collision detection: PASSED")

# Test that pairs occupy correct positions
func test_pair_positions():
	# Horizontal pair occupies two horizontal cells
	var pair = create_pair_at(3, 5, true)
	var positions = game_board.get_pair_positions(3, 5)
	assert_eq(positions.size(), 2, "Pair should occupy 2 cells")
	assert_eq(positions[0], Vector2i(3, 5), "Rune1 at (3,5)")
	assert_eq(positions[1], Vector2i(4, 5), "Rune2 at (4,5)")
	print("✓ Horizontal pair occupies correct positions")
	
	# Vertical pair occupies two vertical cells
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, false)
	positions = game_board.get_pair_positions(3, 5)
	assert_eq(positions.size(), 2, "Pair should occupy 2 cells")
	assert_eq(positions[0], Vector2i(3, 5), "Rune1 at (3,5)")
	assert_eq(positions[1], Vector2i(3, 6), "Rune2 at (3,6)")
	print("✓ Vertical pair occupies correct positions")
	
	print("Pair positions: PASSED")

# Helper functions
func create_pair_at(x: int, y: int, horizontal: bool) -> RunePair:
	var pair = RunePair.new()
	pair.grid_x = x
	pair.grid_y = y
	pair.is_horizontal = horizontal
	game_board.current_pair = pair
	game_board.add_child(pair)
	return pair

func place_element_at(x: int, y: int):
	var element = Element.new()
	element.grid_x = x
	element.grid_y = y
	element.set_element_type(Element.ElementType.FIRE)
	game_board.grid[y][x] = element
	game_board.add_child(element)
