extends GutTest
# Bug Condition Exploration Test for Rune Rotation
# **Validates: Requirements 2.1, 2.2, 2.3, 2.4**
#
# CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists
# DO NOT attempt to fix the test or the code when it fails
# 
# This test encodes the expected behavior - it will validate the fix when it passes after implementation
# GOAL: Surface counterexamples that demonstrate rotation ignores collision and bounds checking

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")

var game_board: GameBoard

func setup_game_board():
	# Create a fresh game board for each test
	game_board = GameBoard.new()
	game_board.initialize_grid()
	# Don't call _ready() to avoid spawning elements and pairs automatically

func cleanup_game_board():
	if game_board:
		game_board.queue_free()
		game_board = null

func run_tests():
	print("\n--- Test 1: Rotation at right edge (x=7 horizontal) ---")
	setup_game_board()
	test_rotation_at_right_edge()
	cleanup_game_board()
	
	print("\n--- Test 2: Rotation with collision below ---")
	setup_game_board()
	test_rotation_with_collision_below()
	cleanup_game_board()
	
	print("\n--- Test 3: Valid rotation in open space ---")
	setup_game_board()
	test_valid_rotation_in_open_space()
	cleanup_game_board()

# Test Case 1: Rotation at right edge should be blocked or wall-kicked
# EXPECTED ON UNFIXED CODE: This test FAILS - rotation succeeds placing rune2 out of bounds
func test_rotation_at_right_edge():
	print("Setting up: Vertical pair at x=7, y=14 (near right and bottom edge)")
	
	# Create a vertical pair at x=7, y=14
	# When vertical: rune1 at (7, 14), rune2 at (7, 15)
	# If we rotate to horizontal: rune1 at (7, 14), rune2 at (8, 14) - OUT OF BOUNDS!
	var pair = RunePair.new()
	pair.grid_x = 7
	pair.grid_y = 14
	pair.is_horizontal = false  # Start vertical
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	print("Initial state: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	print("Rune1 at (7, 14), Rune2 at (7, 15)")
	
	# Attempt rotation to horizontal - on unfixed code, this will succeed
	print("Attempting rotation to horizontal...")
	var initial_orientation = pair.is_horizontal
	game_board.rotate_current_pair()
	
	print("After rotation: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	
	# Check if rotation occurred
	var rotation_occurred = (pair.is_horizontal != initial_orientation)
	
	if rotation_occurred:
		# Rotation happened - check if resulting positions are valid
		var rotated_positions = []
		if pair.is_horizontal:
			rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y))
			rotated_positions.append(Vector2i(pair.grid_x + 1, pair.grid_y))
		
		print("Rotated positions: ", rotated_positions)
		
		# Check if all positions are within bounds
		var all_in_bounds = true
		for pos in rotated_positions:
			if pos.x < 0 or pos.x >= game_board.GRID_WIDTH or pos.y < 0 or pos.y >= game_board.GRID_HEIGHT:
				all_in_bounds = false
				print("COUNTEREXAMPLE: Position ", pos, " is OUT OF BOUNDS! (x=", pos.x, " >= GRID_WIDTH=", game_board.GRID_WIDTH, ")")
		
		# Expected behavior: If rotation occurred, all positions should be valid (either blocked or wall-kicked)
		# On unfixed code: Rotation succeeds placing rune2 at x=8 (out of bounds)
		assert_true(all_in_bounds, "If rotation occurs, all positions must be within bounds (should be blocked or wall-kicked)")
	else:
		print("Rotation was blocked (orientation unchanged)")
		# This is acceptable behavior - rotation was blocked

# Test Case 2: Rotation with piece below should be blocked or wall-kicked
# EXPECTED ON UNFIXED CODE: This test FAILS - rotation succeeds causing overlap
func test_rotation_with_collision_below():
	print("Setting up: Horizontal pair at (3, 5) with element at (3, 6)")
	
	# Place an element at (3, 6)
	var Element = load("res://scripts/element.gd")
	var element = Element.new()
	element.grid_x = 3
	element.grid_y = 6
	game_board.grid[6][3] = element
	game_board.add_child(element)
	
	# Create a horizontal pair at (3, 5)
	var pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	print("Initial state: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	print("Element blocking at (3, 6)")
	
	# Attempt rotation - on unfixed code, this will succeed
	print("Attempting rotation...")
	game_board.rotate_current_pair()
	
	print("After rotation: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	
	# Check if rotation caused overlap
	var rotated_positions = []
	if not pair.is_horizontal:  # After rotation, now vertical
		rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y))
		rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y + 1))
	
	print("Rotated positions: ", rotated_positions)
	
	# Check for collisions
	var has_collision = false
	for pos in rotated_positions:
		if pos.x >= 0 and pos.x < game_board.GRID_WIDTH and pos.y >= 0 and pos.y < game_board.GRID_HEIGHT:
			if game_board.grid[pos.y][pos.x] != null:
				has_collision = true
				print("COLLISION: Position ", pos, " is occupied!")
	
	# Expected behavior: Rotation should be blocked (still horizontal) OR wall-kicked to avoid collision
	# On unfixed code: Rotation succeeds, causing overlap at (3, 6)
	assert_false(has_collision, "Rotation should not cause collision with existing pieces")

# Test Case 3: Valid rotation in open space should succeed
# EXPECTED ON BOTH UNFIXED AND FIXED CODE: This test PASSES
func test_valid_rotation_in_open_space():
	print("Setting up: Horizontal pair at (3, 5) with no obstacles")
	
	# Create a horizontal pair at (3, 5) with clear space
	var pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	print("Initial state: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	
	var initial_orientation = pair.is_horizontal
	
	# Attempt rotation - should succeed
	print("Attempting rotation...")
	game_board.rotate_current_pair()
	
	print("After rotation: pair at (", pair.grid_x, ", ", pair.grid_y, "), horizontal=", pair.is_horizontal)
	
	# Verify rotation occurred
	assert_ne(pair.is_horizontal, initial_orientation, "Rotation should toggle orientation in open space")
	
	# Verify all positions are valid
	var rotated_positions = []
	if pair.is_horizontal:
		rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y))
		rotated_positions.append(Vector2i(pair.grid_x + 1, pair.grid_y))
	else:
		rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y))
		rotated_positions.append(Vector2i(pair.grid_x, pair.grid_y + 1))
	
	print("Rotated positions: ", rotated_positions)
	
	var all_valid = true
	for pos in rotated_positions:
		if pos.x < 0 or pos.x >= game_board.GRID_WIDTH or pos.y < 0 or pos.y >= game_board.GRID_HEIGHT:
			all_valid = false
			print("Position ", pos, " is OUT OF BOUNDS!")
		elif game_board.grid[pos.y][pos.x] != null:
			all_valid = false
			print("Position ", pos, " has COLLISION!")
	
	assert_true(all_valid, "Valid rotation should result in valid positions")
