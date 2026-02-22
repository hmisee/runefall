extends GutTest
# Bug Condition Exploration Test for Level Start Cleanup
# **Validates: Requirements 2.1, 2.2, 2.3**
#
# CRITICAL: This test MUST FAIL on unfixed code - failure confirms the bug exists
# DO NOT attempt to fix the test or the code when it fails
# 
# This test encodes the expected behavior - it will validate the fix when it passes after implementation
# GOAL: Surface counterexamples that demonstrate stale nodes remain after initialize_level()

const GameBoard = preload("res://scripts/game_board.gd")
const RunePair = preload("res://scripts/rune_pair.gd")
const Rune = preload("res://scripts/rune.gd")
const Element = preload("res://scripts/element.gd")

var game_board: GameBoard

func setup_game_board():
	# Create a fresh game board for each test
	game_board = GameBoard.new()
	# Don't call initialize_level yet - we'll do that in tests

func cleanup_game_board():
	if game_board:
		game_board.queue_free()
		game_board = null

func run_tests():
	print("\n--- Test 1: Stale RunePair nodes should be removed ---")
	setup_game_board()
	test_stale_rune_pairs_removed()
	cleanup_game_board()
	
	print("\n--- Test 2: Stale individual Rune nodes should be removed ---")
	setup_game_board()
	test_stale_runes_removed()
	cleanup_game_board()
	
	print("\n--- Test 3: Stale Element nodes should be removed ---")
	setup_game_board()
	test_stale_elements_removed()
	cleanup_game_board()
	
	print("\n--- Test 4: All stale nodes should be removed together ---")
	setup_game_board()
	test_all_stale_nodes_removed()
	cleanup_game_board()

# Test Case 1: Stale RunePair nodes should be removed on initialize_level()
# EXPECTED ON UNFIXED CODE: This test FAILS - old RunePair nodes remain visible
func test_stale_rune_pairs_removed():
	print("Setting up: Creating 2 stale RunePair nodes before initialize_level()")
	
	# Create stale RunePair nodes (simulating previous game session)
	var stale_pair1 = RunePair.new()
	stale_pair1.grid_x = 2
	stale_pair1.grid_y = 5
	game_board.add_child(stale_pair1)
	
	var stale_pair2 = RunePair.new()
	stale_pair2.grid_x = 4
	stale_pair2.grid_y = 8
	game_board.add_child(stale_pair2)
	
	print("Added 2 stale RunePair nodes to game board")
	
	# Count RunePair nodes before initialization
	var pairs_before = count_nodes_of_type(RunePair)
	print("RunePair nodes before initialize_level(): ", pairs_before)
	assert_eq(pairs_before, 2, "Should have 2 stale RunePair nodes before initialization")
	
	# Call initialize_level() - this should clean up old nodes
	print("Calling initialize_level(10)...")
	game_board.initialize_level(10)
	
	# Count RunePair nodes after initialization
	# Expected: Only 1 (the newly spawned current_pair)
	# On unfixed code: 3 (2 stale + 1 new)
	var pairs_after = count_nodes_of_type(RunePair)
	print("RunePair nodes after initialize_level(): ", pairs_after)
	
	if pairs_after > 1:
		print("COUNTEREXAMPLE: Found ", pairs_after - 1, " stale RunePair nodes remaining!")
		print("Expected: 1 (newly spawned pair), Actual: ", pairs_after)
	
	# Expected behavior: Only the newly spawned pair should exist
	assert_eq(pairs_after, 1, "After initialize_level(), only the newly spawned RunePair should exist (stale pairs should be removed)")

# Test Case 2: Stale individual Rune nodes should be removed on initialize_level()
# EXPECTED ON UNFIXED CODE: This test FAILS - old Rune nodes remain visible
func test_stale_runes_removed():
	print("Setting up: Creating 3 stale Rune nodes before initialize_level()")
	
	# Create stale Rune nodes (simulating locked runes from previous game)
	var stale_rune1 = Rune.new()
	stale_rune1.grid_x = 1
	stale_rune1.grid_y = 10
	stale_rune1.rune_type = 0
	game_board.add_child(stale_rune1)
	
	var stale_rune2 = Rune.new()
	stale_rune2.grid_x = 3
	stale_rune2.grid_y = 12
	stale_rune2.rune_type = 1
	game_board.add_child(stale_rune2)
	
	var stale_rune3 = Rune.new()
	stale_rune3.grid_x = 5
	stale_rune3.grid_y = 14
	stale_rune3.rune_type = 2
	game_board.add_child(stale_rune3)
	
	print("Added 3 stale Rune nodes to game board")
	
	# Count Rune nodes before initialization
	var runes_before = count_nodes_of_type(Rune)
	print("Rune nodes before initialize_level(): ", runes_before)
	assert_eq(runes_before, 3, "Should have 3 stale Rune nodes before initialization")
	
	# Call initialize_level() - this should clean up old nodes
	print("Calling initialize_level(10)...")
	game_board.initialize_level(10)
	
	# Count Rune nodes after initialization
	# Expected: 0 (all stale runes removed, new pair hasn't been locked yet)
	# On unfixed code: 3 (stale runes remain)
	var runes_after = count_nodes_of_type(Rune)
	print("Rune nodes after initialize_level(): ", runes_after)
	
	if runes_after > 0:
		print("COUNTEREXAMPLE: Found ", runes_after, " stale Rune nodes remaining!")
		print("Expected: 0 (all stale runes removed), Actual: ", runes_after)
	
	# Expected behavior: All stale runes should be removed
	assert_eq(runes_after, 0, "After initialize_level(), all stale Rune nodes should be removed")

# Test Case 3: Stale Element nodes should be removed on initialize_level()
# EXPECTED ON UNFIXED CODE: This test FAILS - old Element nodes remain visible
func test_stale_elements_removed():
	print("Setting up: Creating 5 stale Element nodes before initialize_level()")
	
	# Create stale Element nodes (simulating elements from previous game)
	for i in range(5):
		var stale_element = Element.new()
		stale_element.grid_x = i
		stale_element.grid_y = 15
		stale_element.set_element_type(i % 4)
		game_board.add_child(stale_element)
	
	print("Added 5 stale Element nodes to game board")
	
	# Count Element nodes before initialization
	var elements_before = count_nodes_of_type(Element)
	print("Element nodes before initialize_level(): ", elements_before)
	assert_eq(elements_before, 5, "Should have 5 stale Element nodes before initialization")
	
	# Call initialize_level(10) - this should clean up old nodes and spawn 10 new elements
	print("Calling initialize_level(10)...")
	game_board.initialize_level(10)
	
	# Count Element nodes after initialization
	# Expected: 10 (newly spawned elements)
	# On unfixed code: 15 (5 stale + 10 new)
	var elements_after = count_nodes_of_type(Element)
	print("Element nodes after initialize_level(): ", elements_after)
	
	if elements_after > 10:
		print("COUNTEREXAMPLE: Found ", elements_after - 10, " stale Element nodes remaining!")
		print("Expected: 10 (newly spawned), Actual: ", elements_after)
	
	# Expected behavior: Only the newly spawned elements should exist
	assert_eq(elements_after, 10, "After initialize_level(10), exactly 10 Element nodes should exist (stale elements should be removed)")

# Test Case 4: All types of stale nodes should be removed together
# EXPECTED ON UNFIXED CODE: This test FAILS - all old nodes remain visible
func test_all_stale_nodes_removed():
	print("Setting up: Creating mixed stale nodes (RunePair, Rune, Element) before initialize_level()")
	
	# Create a mix of stale nodes
	var stale_pair = RunePair.new()
	stale_pair.grid_x = 3
	stale_pair.grid_y = 7
	game_board.add_child(stale_pair)
	
	var stale_rune = Rune.new()
	stale_rune.grid_x = 2
	stale_rune.grid_y = 11
	stale_rune.rune_type = 1
	game_board.add_child(stale_rune)
	
	for i in range(3):
		var stale_element = Element.new()
		stale_element.grid_x = i
		stale_element.grid_y = 14
		stale_element.set_element_type(i % 4)
		game_board.add_child(stale_element)
	
	print("Added 1 RunePair, 1 Rune, and 3 Element stale nodes")
	
	# Count all node types before initialization
	var pairs_before = count_nodes_of_type(RunePair)
	var runes_before = count_nodes_of_type(Rune)
	var elements_before = count_nodes_of_type(Element)
	print("Before initialize_level(): RunePairs=", pairs_before, ", Runes=", runes_before, ", Elements=", elements_before)
	
	# Call initialize_level(8)
	print("Calling initialize_level(8)...")
	game_board.initialize_level(8)
	
	# Count all node types after initialization
	var pairs_after = count_nodes_of_type(RunePair)
	var runes_after = count_nodes_of_type(Rune)
	var elements_after = count_nodes_of_type(Element)
	print("After initialize_level(): RunePairs=", pairs_after, ", Runes=", runes_after, ", Elements=", elements_after)
	
	# Check for counterexamples
	if pairs_after > 1:
		print("COUNTEREXAMPLE: ", pairs_after - 1, " stale RunePair nodes remain!")
	if runes_after > 0:
		print("COUNTEREXAMPLE: ", runes_after, " stale Rune nodes remain!")
	if elements_after > 8:
		print("COUNTEREXAMPLE: ", elements_after - 8, " stale Element nodes remain!")
	
	# Expected behavior: Clean board with only new nodes
	assert_eq(pairs_after, 1, "Should have exactly 1 RunePair (newly spawned)")
	assert_eq(runes_after, 0, "Should have 0 Rune nodes (none locked yet)")
	assert_eq(elements_after, 8, "Should have exactly 8 Element nodes (newly spawned)")

# Helper function to count nodes of a specific type
func count_nodes_of_type(node_type) -> int:
	var count = 0
	for child in game_board.get_children():
		if is_instance_of(child, node_type):
			count += 1
	return count
