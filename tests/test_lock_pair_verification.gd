extends GutTest
# Verification Test for lock_pair() with Four-Way Rotation System
# Task 5.1: Verify lock_pair() works with new rotation system
# **Validates: Requirements 5.1, 5.2, 5.3, 5.4, 5.5**

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")
const Rune = preload("res://scripts/rune.gd")

var game_board: GameBoard

func before_each():
	game_board = GameBoard.new()
	game_board.initialize_grid()

func after_each():
	if game_board:
		game_board.queue_free()
		game_board = null

# Test that get_pair_positions() returns correct order for all rotation states
func test_get_pair_positions_order_all_states():
	print("\n=== Testing get_pair_positions() return order ===")
	
	var test_cases = [
		{"rotation": 0, "x": 3, "y": 5, "rune1_pos": Vector2i(3, 5), "rune2_pos": Vector2i(4, 5), "desc": "State 0: rune1 left, rune2 right"},
		{"rotation": 1, "x": 3, "y": 5, "rune1_pos": Vector2i(3, 5), "rune2_pos": Vector2i(3, 6), "desc": "State 1: rune1 top, rune2 bottom"},
		{"rotation": 2, "x": 3, "y": 5, "rune1_pos": Vector2i(4, 5), "rune2_pos": Vector2i(3, 5), "desc": "State 2: rune2 left, rune1 right"},
		{"rotation": 3, "x": 3, "y": 5, "rune1_pos": Vector2i(3, 6), "rune2_pos": Vector2i(3, 5), "desc": "State 3: rune2 top, rune1 bottom"},
	]
	
	for test_case in test_cases:
		var positions = game_board.get_pair_positions(test_case.x, test_case.y, test_case.rotation)
		assert_eq(positions.size(), 2, test_case.desc + " - returns 2 positions")
		assert_eq(positions[0], test_case.rune1_pos, test_case.desc + " - positions[0] is rune1 position")
		assert_eq(positions[1], test_case.rune2_pos, test_case.desc + " - positions[1] is rune2 position")
		print("  ✓ ", test_case.desc)
		print("    positions[0] (rune1): ", positions[0])
		print("    positions[1] (rune2): ", positions[1])

# Test that lock_pair() places rune1 at positions[0] and rune2 at positions[1]
func test_lock_pair_places_runes_correctly():
	print("\n=== Testing lock_pair() rune placement ===")
	
	var test_cases = [
		{"rotation": 0, "x": 3, "y": 14, "desc": "State 0: Horizontal (rune1 left, rune2 right)"},
		{"rotation": 1, "x": 3, "y": 13, "desc": "State 1: Vertical (rune1 top, rune2 bottom)"},
		{"rotation": 2, "x": 3, "y": 14, "desc": "State 2: Horizontal flipped (rune2 left, rune1 right)"},
		{"rotation": 3, "x": 3, "y": 13, "desc": "State 3: Vertical flipped (rune2 top, rune1 bottom)"},
	]
	
	for test_case in test_cases:
		# Create a fresh game board for each test
		if game_board:
			game_board.queue_free()
		game_board = GameBoard.new()
		game_board.initialize_grid()
		
		# Create pair with specific rotation state
		var pair = create_pair_at(test_case.x, test_case.y, test_case.rotation)
		
		# Store rune references before locking
		var rune1_ref = pair.rune1
		var rune2_ref = pair.rune2
		
		# Get expected positions
		var expected_positions = game_board.get_pair_positions(test_case.x, test_case.y, test_case.rotation)
		
		# Lock the pair
		game_board.lock_pair()
		
		# Verify rune1 is at positions[0]
		var rune1_grid_pos = game_board.grid[expected_positions[0].y][expected_positions[0].x]
		assert_not_null(rune1_grid_pos, test_case.desc + " - rune1 placed in grid")
		assert_eq(rune1_grid_pos.grid_x, expected_positions[0].x, test_case.desc + " - rune1 at correct x")
		assert_eq(rune1_grid_pos.grid_y, expected_positions[0].y, test_case.desc + " - rune1 at correct y")
		
		# Verify rune2 is at positions[1]
		var rune2_grid_pos = game_board.grid[expected_positions[1].y][expected_positions[1].x]
		assert_not_null(rune2_grid_pos, test_case.desc + " - rune2 placed in grid")
		assert_eq(rune2_grid_pos.grid_x, expected_positions[1].x, test_case.desc + " - rune2 at correct x")
		assert_eq(rune2_grid_pos.grid_y, expected_positions[1].y, test_case.desc + " - rune2 at correct y")
		
		print("  ✓ ", test_case.desc)
		print("    rune1 locked at: (", rune1_grid_pos.grid_x, ", ", rune1_grid_pos.grid_y, ")")
		print("    rune2 locked at: (", rune2_grid_pos.grid_x, ", ", rune2_grid_pos.grid_y, ")")

# Test that locked pieces appear at correct grid coordinates for all states
func test_locked_pieces_grid_coordinates():
	print("\n=== Testing locked pieces grid coordinates ===")
	
	# Test each rotation state at different positions
	var test_cases = [
		{"rotation": 0, "x": 2, "y": 10, "expected_coords": [Vector2i(2, 10), Vector2i(3, 10)]},
		{"rotation": 1, "x": 5, "y": 8, "expected_coords": [Vector2i(5, 8), Vector2i(5, 9)]},
		{"rotation": 2, "x": 4, "y": 12, "expected_coords": [Vector2i(5, 12), Vector2i(4, 12)]},
		{"rotation": 3, "x": 6, "y": 7, "expected_coords": [Vector2i(6, 8), Vector2i(6, 7)]},
	]
	
	for test_case in test_cases:
		# Create a fresh game board
		if game_board:
			game_board.queue_free()
		game_board = GameBoard.new()
		game_board.initialize_grid()
		
		# Create and lock pair
		var pair = create_pair_at(test_case.x, test_case.y, test_case.rotation)
		game_board.lock_pair()
		
		# Verify both runes are in the grid at expected coordinates
		var coord1 = test_case.expected_coords[0]
		var coord2 = test_case.expected_coords[1]
		
		var piece1 = game_board.grid[coord1.y][coord1.x]
		var piece2 = game_board.grid[coord2.y][coord2.x]
		
		assert_not_null(piece1, "Rotation " + str(test_case.rotation) + " - piece at " + str(coord1))
		assert_not_null(piece2, "Rotation " + str(test_case.rotation) + " - piece at " + str(coord2))
		
		assert_eq(piece1.grid_x, coord1.x, "Piece1 grid_x matches")
		assert_eq(piece1.grid_y, coord1.y, "Piece1 grid_y matches")
		assert_eq(piece2.grid_x, coord2.x, "Piece2 grid_x matches")
		assert_eq(piece2.grid_y, coord2.y, "Piece2 grid_y matches")
		
		print("  ✓ Rotation ", test_case.rotation, " at (", test_case.x, ",", test_case.y, ")")
		print("    Locked at: ", coord1, " and ", coord2)

# Test horizontal states (0, 2) place runes in same row
func test_horizontal_states_same_row():
	print("\n=== Testing horizontal states place runes in same row ===")
	
	for rotation in [0, 2]:
		# Create a fresh game board
		if game_board:
			game_board.queue_free()
		game_board = GameBoard.new()
		game_board.initialize_grid()
		
		var pair = create_pair_at(3, 10, rotation)
		var positions = game_board.get_pair_positions(3, 10, rotation)
		
		# Both positions should have same y coordinate
		assert_eq(positions[0].y, positions[1].y, "Rotation " + str(rotation) + " - both runes in same row")
		
		# Lock and verify
		game_board.lock_pair()
		var piece1 = game_board.grid[positions[0].y][positions[0].x]
		var piece2 = game_board.grid[positions[1].y][positions[1].x]
		
		assert_eq(piece1.grid_y, piece2.grid_y, "Rotation " + str(rotation) + " - locked runes in same row")
		print("  ✓ Rotation ", rotation, " - runes locked in row ", piece1.grid_y)

# Test vertical states (1, 3) place runes in same column
func test_vertical_states_same_column():
	print("\n=== Testing vertical states place runes in same column ===")
	
	for rotation in [1, 3]:
		# Create a fresh game board
		if game_board:
			game_board.queue_free()
		game_board = GameBoard.new()
		game_board.initialize_grid()
		
		var pair = create_pair_at(3, 10, rotation)
		var positions = game_board.get_pair_positions(3, 10, rotation)
		
		# Both positions should have same x coordinate
		assert_eq(positions[0].x, positions[1].x, "Rotation " + str(rotation) + " - both runes in same column")
		
		# Lock and verify
		game_board.lock_pair()
		var piece1 = game_board.grid[positions[0].y][positions[0].x]
		var piece2 = game_board.grid[positions[1].y][positions[1].x]
		
		assert_eq(piece1.grid_x, piece2.grid_x, "Rotation " + str(rotation) + " - locked runes in same column")
		print("  ✓ Rotation ", rotation, " - runes locked in column ", piece1.grid_x)

# Helper function to create a pair at specific position with specific rotation
func create_pair_at(x: int, y: int, rotation: int) -> RunePair:
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
	pair.rotation_state = rotation
	pair.update_positions()
	game_board.current_pair = pair
	game_board.add_child(pair)
	return pair
