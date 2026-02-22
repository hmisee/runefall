extends GutTest
# Property-Based Preservation Tests for Rune Rotation Fix
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
#
# Property 4: Preservation - Non-Rotation Input Behavior
# For any input that is NOT the rotation key, behavior should remain unchanged
#
# IMPORTANT: These tests should PASS on UNFIXED code (baseline behavior)
# These tests should PASS on FIXED code (no regressions)

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
	print("\n=== PROPERTY-BASED PRESERVATION TESTS ===")
	print("Testing that non-rotation behavior remains unchanged\n")
	
	print("--- Property 1: Horizontal Movement Preservation ---")
	setup_game_board()
	test_property_horizontal_movement()
	cleanup_game_board()
	
	print("\n--- Property 2: Vertical Movement Preservation ---")
	setup_game_board()
	test_property_vertical_movement()
	cleanup_game_board()
	
	print("\n--- Property 3: Collision Preservation ---")
	setup_game_board()
	test_property_collision_detection()
	cleanup_game_board()
	
	print("\n--- Property 4: Pair Orientation Preservation ---")
	setup_game_board()
	test_property_pair_orientations()
	cleanup_game_board()
	
	print("\n--- Property 5: Locking Behavior Preservation ---")
	setup_game_board()
	test_property_locking_behavior()
	cleanup_game_board()

# Property 1: Horizontal movement works correctly with collision checking
# Validates: Requirement 3.1
func test_property_horizontal_movement():
	print("Testing horizontal movement across multiple scenarios...")
	
	var test_cases = [
		{"x": 3, "y": 5, "horizontal": true, "direction": 1, "expected_x": 4, "desc": "Move right in open space"},
		{"x": 4, "y": 5, "horizontal": true, "direction": -1, "expected_x": 3, "desc": "Move left in open space"},
		{"x": 0, "y": 5, "horizontal": true, "direction": -1, "expected_x": 0, "desc": "Blocked at left edge"},
		{"x": 6, "y": 5, "horizontal": true, "direction": 1, "expected_x": 6, "desc": "Horizontal pair blocked at right edge"},
		{"x": 6, "y": 5, "horizontal": false, "direction": 1, "expected_x": 7, "desc": "Vertical pair can reach x=7"},
	]
	
	for test_case in test_cases:
		var pair = create_pair_at(test_case.x, test_case.y, test_case.horizontal)
		game_board.move_pair_horizontal(test_case.direction)
		assert_eq(pair.grid_x, test_case.expected_x, test_case.desc)
		print("  ✓ ", test_case.desc, ": ", test_case.x, " -> ", pair.grid_x)
		cleanup_game_board()
		setup_game_board()
	
	# Test collision blocking
	var pair = create_pair_at(2, 5, true)
	place_element_at(5, 5)
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 2, "Movement blocked by element")
	print("  ✓ Movement blocked by element collision")
	
	print("Horizontal movement preservation: PASSED")

# Property 2: Vertical movement (fall and down key) works correctly
# Validates: Requirement 3.2
func test_property_vertical_movement():
	print("Testing vertical movement across multiple scenarios...")
	
	# Test downward movement in open space
	var pair = create_pair_at(3, 5, true)
	var initial_y = pair.grid_y
	game_board.move_pair_down()
	assert_eq(pair.grid_y, initial_y + 1, "Pair moves down in open space")
	print("  ✓ Pair moves down: y=", initial_y, " -> y=", pair.grid_y)
	
	# Test multiple downward movements
	for i in range(3):
		initial_y = pair.grid_y
		game_board.move_pair_down()
		assert_eq(pair.grid_y, initial_y + 1, "Pair continues moving down")
	print("  ✓ Pair continues moving down through multiple steps")
	
	# Test locking at bottom
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 14, true)
	game_board.move_pair_down()  # Should lock at y=15
	var new_pair = game_board.current_pair
	assert_true(new_pair != pair, "Original pair locked, new pair spawned")
	print("  ✓ Pair locks at bottom and new pair spawns")
	
	# Test collision blocking vertical movement
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, true)
	place_element_at(3, 7)
	game_board.move_pair_down()  # Move to y=6
	assert_eq(pair.grid_y, 6, "Pair moves to y=6")
	game_board.move_pair_down()  # Should lock because element at (3,7)
	new_pair = game_board.current_pair
	assert_true(new_pair != pair, "Pair locks when blocked by element")
	print("  ✓ Pair locks when blocked by element below")
	
	print("Vertical movement preservation: PASSED")

# Property 3: Collision detection works for all movement types
# Validates: Requirements 3.1, 3.2
func test_property_collision_detection():
	print("Testing collision detection across multiple scenarios...")
	
	# Horizontal collision
	var pair = create_pair_at(2, 5, true)
	place_element_at(4, 5)
	var initial_x = pair.grid_x
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, initial_x, "Horizontal movement blocked by collision")
	print("  ✓ Horizontal collision detected and blocks movement")
	
	# Vertical collision with horizontal pair
	place_element_at(2, 7)
	game_board.move_pair_down()  # Move to y=6
	assert_eq(pair.grid_y, 6, "Pair moves to y=6")
	game_board.move_pair_down()  # Should lock
	assert_true(game_board.current_pair != pair, "Pair locks on vertical collision")
	print("  ✓ Vertical collision detected and triggers lock")
	
	# Vertical collision with vertical pair
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, false)
	place_element_at(3, 7)
	game_board.move_pair_down()  # Should be blocked because rune2 would be at (3,7)
	assert_eq(pair.grid_y, 5, "Vertical pair blocked by collision at rune2 position")
	print("  ✓ Vertical pair collision detected at rune2 position")
	
	print("Collision detection preservation: PASSED")

# Property 4: Pairs correctly occupy positions based on orientation
# Validates: Requirements 3.5, 3.6
func test_property_pair_orientations():
	print("Testing pair position calculations for both orientations...")
	
	# Horizontal pair occupies two horizontal cells
	var pair = create_pair_at(3, 5, true)
	var positions = game_board.get_pair_positions(3, 5)
	assert_eq(positions.size(), 2, "Pair occupies 2 cells")
	assert_eq(positions[0], Vector2i(3, 5), "Horizontal: rune1 at (3,5)")
	assert_eq(positions[1], Vector2i(4, 5), "Horizontal: rune2 at (4,5)")
	print("  ✓ Horizontal pair: rune1=(3,5), rune2=(4,5)")
	
	# Vertical pair occupies two vertical cells
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, false)
	positions = game_board.get_pair_positions(3, 5)
	assert_eq(positions.size(), 2, "Pair occupies 2 cells")
	assert_eq(positions[0], Vector2i(3, 5), "Vertical: rune1 at (3,5)")
	assert_eq(positions[1], Vector2i(3, 6), "Vertical: rune2 at (3,6)")
	print("  ✓ Vertical pair: rune1=(3,5), rune2=(3,6)")
	
	# Test at different positions
	var test_positions = [
		{"x": 0, "y": 0, "horizontal": true},
		{"x": 7, "y": 10, "horizontal": false},
		{"x": 4, "y": 8, "horizontal": true},
	]
	
	for test_pos in test_positions:
		cleanup_game_board()
		setup_game_board()
		pair = create_pair_at(test_pos.x, test_pos.y, test_pos.horizontal)
		positions = game_board.get_pair_positions(test_pos.x, test_pos.y)
		assert_eq(positions.size(), 2, "Pair always occupies 2 cells")
		if test_pos.horizontal:
			assert_eq(positions[1].x, test_pos.x + 1, "Horizontal: rune2 is +1 in x")
			assert_eq(positions[1].y, test_pos.y, "Horizontal: rune2 same y")
		else:
			assert_eq(positions[1].x, test_pos.x, "Vertical: rune2 same x")
			assert_eq(positions[1].y, test_pos.y + 1, "Vertical: rune2 is +1 in y")
	
	print("  ✓ Position calculations correct across multiple positions")
	print("Pair orientation preservation: PASSED")

# Property 5: Locking behavior works correctly for both orientations
# Validates: Requirement 3.3
func test_property_locking_behavior():
	print("Testing locking behavior for both orientations...")
	
	# Horizontal pair locking
	var pair = create_pair_at(3, 14, true)
	game_board.move_pair_down()  # Locks at y=15
	
	# Check that runes are placed in grid
	var has_rune_at_3_15 = game_board.grid[15][3] != null
	var has_rune_at_4_15 = game_board.grid[15][4] != null
	assert_true(has_rune_at_3_15, "Horizontal lock: rune at (3,15)")
	assert_true(has_rune_at_4_15, "Horizontal lock: rune at (4,15)")
	print("  ✓ Horizontal pair locks and places runes at (3,15) and (4,15)")
	
	# Vertical pair locking
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 14, false)
	game_board.move_pair_down()  # Locks at y=15, rune2 at y=14
	
	has_rune_at_3_15 = game_board.grid[15][3] != null
	var has_rune_at_3_14 = game_board.grid[14][3] != null
	assert_true(has_rune_at_3_15, "Vertical lock: rune at (3,15)")
	assert_true(has_rune_at_3_14, "Vertical lock: rune at (3,14)")
	print("  ✓ Vertical pair locks and places runes at (3,15) and (3,14)")
	
	# Test locking when blocked by element
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, true)
	place_element_at(3, 7)
	game_board.move_pair_down()  # Move to y=6
	game_board.move_pair_down()  # Should lock at y=6
	
	var has_rune_at_3_6 = game_board.grid[6][3] != null
	var has_rune_at_4_6 = game_board.grid[6][4] != null
	assert_true(has_rune_at_3_6, "Lock on collision: rune at (3,6)")
	assert_true(has_rune_at_4_6, "Lock on collision: rune at (4,6)")
	print("  ✓ Pair locks correctly when blocked by element")
	
	print("Locking behavior preservation: PASSED")

# Helper functions

func create_pair_at(x: int, y: int, horizontal: bool) -> RunePair:
	var pair = RunePair.new()
	# Manually initialize runes since _ready() is called deferred
	pair.rune1 = Rune.new()
	pair.rune2 = Rune.new()
	pair.add_child(pair.rune1)
	pair.add_child(pair.rune2)
	pair.rune1.set_rune_type(Rune.RuneType.FIRE)
	pair.rune2.set_rune_type(Rune.RuneType.WATER)
	
	pair.grid_x = x
	pair.grid_y = y
	pair.is_horizontal = horizontal
	pair.update_positions()
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
