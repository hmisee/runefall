# Direct Preservation Property Tests (no GutTest base class)
# **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6**

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")
const Element = preload("res://scripts/element.gd")

static func run_all_tests():
	print("\n=== PRESERVATION PROPERTY TESTS ===\n")
	
	test_horizontal_movement()
	test_vertical_movement()
	test_collision_detection()
	test_pair_positions()
	
	print("\n=== All Preservation Tests Complete ===")

static func test_horizontal_movement():
	print("--- Test 1: Horizontal Movement ---")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	# Move right
	game_board.move_pair_horizontal(1)
	assert(pair.grid_x == 4, "Should move right")
	print("✓ Move right: (3,5) -> (4,5)")
	
	# Move left
	game_board.move_pair_horizontal(-1)
	assert(pair.grid_x == 3, "Should move left")
	print("✓ Move left: (4,5) -> (3,5)")
	
	# Cannot move left at edge
	pair.grid_x = 0
	game_board.move_pair_horizontal(-1)
	assert(pair.grid_x == 0, "Should not move past left edge")
	print("✓ Blocked at left edge")
	
	# Horizontal pair cannot move to x=7
	pair.grid_x = 6
	pair.is_horizontal = true
	game_board.move_pair_horizontal(1)
	assert(pair.grid_x == 6, "Horizontal pair blocked at right edge")
	print("✓ Horizontal pair blocked at right edge")
	
	# Vertical pair can move to x=7
	pair.is_horizontal = false
	game_board.move_pair_horizontal(1)
	assert(pair.grid_x == 7, "Vertical pair can reach x=7")
	print("✓ Vertical pair can reach x=7")
	
	game_board.queue_free()
	print("Horizontal movement: PASSED\n")

static func test_vertical_movement():
	print("--- Test 2: Vertical Movement ---")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	# Move down
	var initial_y = pair.grid_y
	game_board.move_pair_down()
	assert(pair.grid_y == initial_y + 1, "Should move down")
	print("✓ Move down: (3,5) -> (3,6)")
	
	game_board.queue_free()
	print("Vertical movement: PASSED\n")

static func test_collision_detection():
	print("--- Test 3: Collision Detection ---")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var pair = RunePair.new()
	pair.grid_x = 2
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	# Place element blocking horizontal movement
	var element = Element.new()
	element.grid_x = 4
	element.grid_y = 5
	element.set_element_type(Element.ElementType.FIRE)
	game_board.grid[5][4] = element
	game_board.add_child(element)
	
	# Try to move right - blocked
	game_board.move_pair_horizontal(1)
	assert(pair.grid_x == 2, "Should not move through element")
	print("✓ Horizontal movement blocked by collision")
	
	game_board.queue_free()
	
	# Test vertical collision
	game_board = GameBoard.new()
	game_board.initialize_grid()
	
	pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = false
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	element = Element.new()
	element.grid_x = 3
	element.grid_y = 7
	element.set_element_type(Element.ElementType.FIRE)
	game_board.grid[7][3] = element
	game_board.add_child(element)
	
	# Try to move down - blocked
	game_board.move_pair_down()
	assert(pair.grid_y == 5, "Vertical pair should not move into collision")
	print("✓ Vertical pair blocked by collision")
	
	game_board.queue_free()
	print("Collision detection: PASSED\n")

static func test_pair_positions():
	print("--- Test 4: Pair Positions ---")
	var game_board = GameBoard.new()
	game_board.initialize_grid()
	
	var pair = RunePair.new()
	pair.grid_x = 3
	pair.grid_y = 5
	pair.is_horizontal = true
	game_board.current_pair = pair
	game_board.add_child(pair)
	
	# Horizontal pair
	var positions = game_board.get_pair_positions(3, 5)
	assert(positions.size() == 2, "Pair should occupy 2 cells")
	assert(positions[0] == Vector2i(3, 5), "Rune1 at (3,5)")
	assert(positions[1] == Vector2i(4, 5), "Rune2 at (4,5)")
	print("✓ Horizontal pair occupies correct positions")
	
	# Vertical pair
	pair.is_horizontal = false
	positions = game_board.get_pair_positions(3, 5)
	assert(positions.size() == 2, "Pair should occupy 2 cells")
	assert(positions[0] == Vector2i(3, 5), "Rune1 at (3,5)")
	assert(positions[1] == Vector2i(3, 6), "Rune2 at (3,6)")
	print("✓ Vertical pair occupies correct positions")
	
	game_board.queue_free()
	print("Pair positions: PASSED\n")
