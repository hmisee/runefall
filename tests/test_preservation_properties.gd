extends GutTest
# Preservation Property Tests for Rune Rotation Fix
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**
#
# IMPORTANT: These tests verify that non-rotation behavior remains unchanged
# These tests should PASS on UNFIXED code (baseline behavior)
# These tests should PASS on FIXED code (no regressions)
#
# Property 4: Preservation - Non-Rotation Input Behavior
# For any input that is NOT the rotation key, behavior should remain unchanged

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
	print("\n=== PRESERVATION PROPERTY TESTS ===")
	print("Testing that non-rotation behavior remains unchanged\n")
	
	print("\n--- Property Test 1: Horizontal Movement Preservation ---")
	setup_game_board()
	test_horizontal_movement_preservation()
	cleanup_game_board()
	
	print("\n--- Property Test 2: Vertical Movement Preservation ---")
	setup_game_board()
	test_vertical_movement_preservation()
	cleanup_game_board()
	
	print("\n--- Property Test 3: Locking Preservation (Horizontal) ---")
	setup_game_board()
	test_locking_preservation_horizontal()
	cleanup_game_board()
	
	print("\n--- Property Test 4: Locking Preservation (Vertical) ---")
	setup_game_board()
	test_locking_preservation_vertical()
	cleanup_game_board()
	
	print("\n--- Property Test 5: Match Detection Preservation ---")
	setup_game_board()
	test_match_detection_preservation()
	cleanup_game_board()
	
	print("\n--- Property Test 6: Collision Detection Preservation ---")
	setup_game_board()
	test_collision_detection_preservation()
	cleanup_game_board()

# Property Test 1: Horizontal Movement with Collision Checking
# Validates: Requirement 3.1 - Left/right movement works with proper collision checking
func test_horizontal_movement_preservation():
	print("Testing horizontal movement behavior...")
	
	# Test Case 1: Move right in open space
	var pair = create_pair_at(3, 5, true)
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 4, "Pair should move right in open space")
	print("✓ Move right in open space: (3,5) -> (4,5)")
	
	# Test Case 2: Move left in open space
	game_board.move_pair_horizontal(-1)
	assert_eq(pair.grid_x, 3, "Pair should move left in open space")
	print("✓ Move left in open space: (4,5) -> (3,5)")
	
	# Test Case 3: Cannot move left at left edge
	pair.grid_x = 0
	game_board.move_pair_horizontal(-1)
	assert_eq(pair.grid_x, 0, "Pair should not move left past left edge")
	print("✓ Blocked at left edge: stays at (0,5)")
	
	# Test Case 4: Cannot move right at right edge (horizontal pair)
	pair.grid_x = 6  # Horizontal pair needs 2 cells, so max is 6
	pair.is_horizontal = true
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 6, "Horizontal pair should not move right past right edge")
	print("✓ Blocked at right edge (horizontal): stays at (6,5)")
	
	# Test Case 5: Vertical pair can move to x=7
	pair.grid_x = 6
	pair.is_horizontal = false
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 7, "Vertical pair should move to x=7")
	print("✓ Vertical pair can reach x=7: (6,5) -> (7,5)")
	
	# Test Case 6: Cannot move through existing pieces
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, true)
	place_element_at(5, 5)
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 3, "Pair should not move through existing pieces")
	print("✓ Blocked by element at (5,5): stays at (3,5)")
	
	print("Horizontal movement preservation: PASSED")

# Property Test 2: Vertical Movement (Fall and Down Key)
# Validates: Requirement 3.2 - Automatic fall and down-key acceleration work correctly
func test_vertical_movement_preservation():
	print("Testing vertical movement behavior...")
	
	# Test Case 1: Move down in open space
	var pair = create_pair_at(3, 5, true)
	var initial_y = pair.grid_y
	game_board.move_pair_down()
	assert_eq(pair.grid_y, initial_y + 1, "Pair should move down in open space")
	print("✓ Move down in open space: (3,5) -> (3,6)")
	
	# Test Case 2: Cannot move down at bottom
	pair.grid_y = 15
	pair.is_horizontal = true
	var y_before = pair.grid_y
	game_board.move_pair_down()
	# Should trigger lock_pair, so current_pair becomes null
	assert_true(game_board.current_pair == null or game_board.current_pair != pair, "Pair should lock at bottom")
	print("✓ Pair locks at bottom (y=15)")
	
	# Test Case 3: Cannot move down when blocked by piece
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, true)
	place_element_at(3, 7)
	game_board.move_pair_down()
	assert_eq(pair.grid_y, 6, "Pair should move to y=6")
	game_board.move_pair_down()
	# Should lock because element at (3,7) blocks further movement
	assert_true(game_board.current_pair == null or game_board.current_pair != pair, "Pair should lock when blocked by element")
	print("✓ Pair locks when blocked by element at (3,7)")
	
	print("Vertical movement preservation: PASSED")

# Property Test 3: Locking Preservation (Horizontal Orientation)
# Validates: Requirement 3.3, 3.5 - Pairs lock and separate correctly when horizontal
func test_locking_preservation_horizontal():
	print("Testing locking behavior for horizontal pairs...")
	
	var pair = create_pair_at(3, 14, true)  # Near bottom
	pair.rune1.set_rune_type(Rune.RuneType.FIRE)
	pair.rune2.set_rune_type(Rune.RuneType.WATER)
	
	# Move down to trigger lock
	game_board.move_pair_down()
	
	# Verify pair is locked (current_pair is null or new pair spawned)
	assert_true(game_board.current_pair == null or game_board.current_pair != pair, 
		"Original pair should be locked")
	print("✓ Horizontal pair locked")
	
	# Verify runes are placed correctly in grid
	assert_true(game_board.grid[15][3] != null, "Rune1 should be at (3,15)")
	assert_true(game_board.grid[15][4] != null, "Rune2 should be at (4,15)")
	print("✓ Runes placed at correct positions: (3,15) and (4,15)")
	
	# Verify runes are of correct type
	var rune1_in_grid = game_board.grid[15][3]
	var rune2_in_grid = game_board.grid[15][4]
	assert_true(rune1_in_grid is Rune, "Grid cell (3,15) should contain a Rune")
	assert_true(rune2_in_grid is Rune, "Grid cell (4,15) should contain a Rune")
	print("✓ Grid cells contain Rune objects")
	
	print("Locking preservation (horizontal): PASSED")

# Property Test 4: Locking Preservation (Vertical Orientation)
# Validates: Requirement 3.3, 3.6 - Pairs lock and separate correctly when vertical
func test_locking_preservation_vertical():
	print("Testing locking behavior for vertical pairs...")
	
	var pair = create_pair_at(3, 14, false)  # Vertical, near bottom
	pair.rune1.set_rune_type(Rune.RuneType.EARTH)
	pair.rune2.set_rune_type(Rune.RuneType.AIR)
	
	# Move down to trigger lock
	game_board.move_pair_down()
	
	# Verify pair is locked
	assert_true(game_board.current_pair == null or game_board.current_pair != pair,
		"Original pair should be locked")
	print("✓ Vertical pair locked")
	
	# Verify runes are placed correctly in grid
	assert_true(game_board.grid[15][3] != null, "Rune1 should be at (3,15)")
	assert_true(game_board.grid[14][3] != null, "Rune2 should be at (3,14)")
	print("✓ Runes placed at correct positions: (3,15) and (3,14)")
	
	# Verify runes are of correct type
	var rune1_in_grid = game_board.grid[15][3]
	var rune2_in_grid = game_board.grid[14][3]
	assert_true(rune1_in_grid is Rune, "Grid cell (3,15) should contain a Rune")
	assert_true(rune2_in_grid is Rune, "Grid cell (3,14) should contain a Rune")
	print("✓ Grid cells contain Rune objects")
	
	print("Locking preservation (vertical): PASSED")

# Property Test 5: Match Detection After Locking
# Validates: Requirement 3.4 - Match-4 detection works after pairs lock
func test_match_detection_preservation():
	print("Testing match detection behavior...")
	
	# Setup: Create a horizontal match-4 scenario
	# Place 2 runes manually, then lock a pair to complete the match
	place_rune_at(2, 15, Rune.RuneType.FIRE)
	place_rune_at(3, 15, Rune.RuneType.FIRE)
	
	# Create a pair that will complete the match
	var pair = create_pair_at(4, 14, true)
	pair.rune1.set_rune_type(Rune.RuneType.FIRE)
	pair.rune2.set_rune_type(Rune.RuneType.FIRE)
	
	# Lock the pair - this calls check_matches() internally
	game_board.move_pair_down()
	
	# Verify the matched pieces were removed (check_matches is called synchronously in lock_pair)
	assert_true(game_board.grid[15][2] == null, "Matched piece at (2,15) should be removed")
	assert_true(game_board.grid[15][3] == null, "Matched piece at (3,15) should be removed")
	assert_true(game_board.grid[15][4] == null, "Matched piece at (4,15) should be removed")
	assert_true(game_board.grid[15][5] == null, "Matched piece at (5,15) should be removed")
	print("✓ Horizontal match-4 detected and removed")
	
	# Test vertical match
	cleanup_game_board()
	setup_game_board()
	
	place_rune_at(3, 14, Rune.RuneType.WATER)
	place_rune_at(3, 15, Rune.RuneType.WATER)
	
	pair = create_pair_at(3, 12, false)
	pair.rune1.set_rune_type(Rune.RuneType.WATER)
	pair.rune2.set_rune_type(Rune.RuneType.WATER)
	
	game_board.move_pair_down()  # Locks at (3,12) and (3,13), completes match with (3,14) and (3,15)
	
	assert_true(game_board.grid[12][3] == null, "Matched piece at (3,12) should be removed")
	assert_true(game_board.grid[13][3] == null, "Matched piece at (3,13) should be removed")
	assert_true(game_board.grid[14][3] == null, "Matched piece at (3,14) should be removed")
	assert_true(game_board.grid[15][3] == null, "Matched piece at (3,15) should be removed")
	print("✓ Vertical match-4 detected and removed")
	
	print("Match detection preservation: PASSED")

# Property Test 6: Collision Detection for Movement
# Validates: Requirements 3.1, 3.2 - Collision checking works for all movement
func test_collision_detection_preservation():
	print("Testing collision detection behavior...")
	
	# Test horizontal collision
	var pair = create_pair_at(2, 5, true)
	place_element_at(4, 5)
	
	# Try to move right - should be blocked by element at (4,5)
	game_board.move_pair_horizontal(1)
	assert_eq(pair.grid_x, 2, "Should not move through element")
	print("✓ Horizontal movement blocked by collision")
	
	# Test vertical collision
	place_element_at(2, 7)
	game_board.move_pair_down()
	assert_eq(pair.grid_y, 6, "Should move to y=6")
	game_board.move_pair_down()
	assert_true(game_board.current_pair == null or game_board.current_pair != pair, "Should lock when blocked vertically")
	print("✓ Vertical movement blocked by collision, pair locks")
	
	# Test collision with vertical pair
	cleanup_game_board()
	setup_game_board()
	pair = create_pair_at(3, 5, false)  # Vertical
	place_element_at(3, 7)
	
	game_board.move_pair_down()  # Move to y=6, rune2 at y=7 (blocked)
	# Actually, when checking can_place_pair(3, 6), it checks (3,6) and (3,7)
	# Element at (3,7) blocks this
	assert_eq(pair.grid_y, 5, "Vertical pair should not move into collision")
	print("✓ Vertical pair blocked by collision at rune2 position")
	
	print("Collision detection preservation: PASSED")

# Helper functions

func create_pair_at(x: int, y: int, horizontal: bool) -> RunePair:
	var pair = RunePair.new()
	# Manually initialize runes since _ready() is called deferred
	pair.rune1 = Rune.new()
	pair.rune2 = Rune.new()
	pair.add_child(pair.rune1)
	pair.add_child(pair.rune2)
	pair.rune1.set_rune_type(Rune.RuneType.FIRE)  # Default type for testing
	pair.rune2.set_rune_type(Rune.RuneType.WATER)  # Default type for testing
	
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

func place_rune_at(x: int, y: int, rune_type: Rune.RuneType):
	var rune = Rune.new()
	rune.grid_x = x
	rune.grid_y = y
	rune.set_rune_type(rune_type)
	game_board.grid[y][x] = rune
	game_board.add_child(rune)
