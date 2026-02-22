extends Node2D
class_name GameBoard

const GRID_WIDTH = 8
const GRID_HEIGHT = 16
const CELL_SIZE = 50
const LEVEL_CONFIG = {
	1: { "elements": 10, "name": "Calm Beginnings" },
	2: { "elements": 15, "name": "Rising Chaos" },
	3: { "elements": 20, "name": "Elemental Storm" }
}

var grid = []
var current_pair: RunePair
var fall_timer = 0.0
var fall_speed = 0.5
var initial_element_count: int = 10
var game_active: bool = true
var next_rune_pair_data: Dictionary = {}
var paused: bool = false

signal game_over
signal win_condition_met()
signal loss_condition_met()
signal elements_remaining_changed(count: int)
signal preview_updated(rune1_type: int, rune2_type: int, rotation: int)

func _ready():
	initialize_level(initial_element_count)

func draw_boundaries():
	queue_redraw()

func _draw():
	# Draw grid boundaries
	var border_color = Color.WHITE
	var grid_rect = Rect2(0, 0, GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	draw_rect(grid_rect, border_color, false, 3)
	
	# Draw grid lines
	for x in range(1, GRID_WIDTH):
		var line_start = Vector2(x * CELL_SIZE, 0)
		var line_end = Vector2(x * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
		draw_line(line_start, line_end, Color(0.3, 0.3, 0.3), 1)
	
	for y in range(1, GRID_HEIGHT):
		var line_start = Vector2(0, y * CELL_SIZE)
		var line_end = Vector2(GRID_WIDTH * CELL_SIZE, y * CELL_SIZE)
		draw_line(line_start, line_end, Color(0.3, 0.3, 0.3), 1)

func cleanup_board():
	# Remove all RunePair, Rune, and Element child nodes
	# We need to collect nodes first, then free them, to avoid modifying the array while iterating
	var nodes_to_remove = []
	for child in get_children():
		if child is RunePair or child is Rune or child is Element:
			nodes_to_remove.append(child)
	
	# Now free all collected nodes
	for node in nodes_to_remove:
		node.queue_free()
		# Also remove from parent immediately to ensure it's not counted
		remove_child(node)

func initialize_grid():
	# Clean up any existing game objects before reinitializing
	cleanup_board()
	
	grid.resize(GRID_HEIGHT)
	for y in range(GRID_HEIGHT):
		grid[y] = []
		grid[y].resize(GRID_WIDTH)
		for x in range(GRID_WIDTH):
			grid[y][x] = null

func spawn_elements():
	# Spawn some random elements at the bottom
	for i in range(10):
		var x = randi() % GRID_WIDTH
		var y = GRID_HEIGHT - 1 - (i / GRID_WIDTH)
		if grid[y][x] == null:
			var element = Element.new()
			element.set_element_type(randi() % 4)
			element.grid_x = x
			element.grid_y = y
			element.position = grid_to_world(x, y)
			grid[y][x] = element
			add_child(element)

func initialize_level(element_count: int) -> void:
	fall_speed = 0.5
	# Clear the board
	initialize_grid()
	draw_boundaries()
	
	# Spawn specified number of elements
	spawn_initial_elements(element_count)
	
	# Check if spawn position is available
	if not check_spawn_availability():
		push_warning("Spawn blocked after initialization, clearing top rows")
		clear_top_rows(2)
	
	# Initialize preview and spawn first pair
	next_rune_pair_data = generate_next_pair_data()
	spawn_new_pair()

func spawn_initial_elements(element_count: int) -> void:
	# Spawn specified number of elements randomly at the bottom
	# Use a retry mechanism to ensure we spawn the requested count
	var spawned_count = 0
	var max_attempts = element_count * 10  # Allow many attempts to handle collisions
	var attempt = 0
	
	while spawned_count < element_count and attempt < max_attempts:
		var x = randi() % GRID_WIDTH
		var y = GRID_HEIGHT - 1 - (spawned_count / GRID_WIDTH)
		if grid[y][x] == null:
			var element = Element.new()
			element.set_element_type(randi() % 4)
			element.grid_x = x
			element.grid_y = y
			element.position = grid_to_world(x, y)
			grid[y][x] = element
			add_child(element)
			spawned_count += 1
		attempt += 1

func clear_top_rows(row_count: int) -> void:
	# Clear the top N rows to ensure spawn position is available
	for y in range(row_count):
		for x in range(GRID_WIDTH):
			if grid[y][x] != null:
				var piece = grid[y][x]
				grid[y][x] = null
				piece.queue_free()

func generate_next_pair_data() -> Dictionary:
	return {
		"rune1_type": randi() % 4,
		"rune2_type": randi() % 4,
		"rotation": 0
	}

func spawn_new_pair():
	if not game_active:
		return
	
	# Check if spawn position is available
	if not check_spawn_availability():
		loss_condition_met.emit()
		return
	
	current_pair = RunePair.new()
	# Use preview data to set rune types
	current_pair.use_preview_data = true
	current_pair.preview_rune1_type = next_rune_pair_data["rune1_type"]
	current_pair.preview_rune2_type = next_rune_pair_data["rune2_type"]
	current_pair.grid_x = GRID_WIDTH / 2
	current_pair.grid_y = 0
	# Position at top-left of the cell (rune1 will be at 0,0 relative to pair)
	current_pair.position = Vector2(current_pair.grid_x * CELL_SIZE, current_pair.grid_y * CELL_SIZE)
	add_child(current_pair)
	
	# Generate preview data for the next pair
	next_rune_pair_data = generate_next_pair_data()
	
	# Emit signals to update UI
	preview_updated.emit(next_rune_pair_data["rune1_type"], next_rune_pair_data["rune2_type"], next_rune_pair_data["rotation"])
	elements_remaining_changed.emit(get_element_count())

func grid_to_world(x: int, y: int) -> Vector2:
	# Return center of cell for individual pieces
	return Vector2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2)

func grid_to_world_pair(x: int, y: int) -> Vector2:
	# Return top-left corner for pairs
	return Vector2(x * CELL_SIZE, y * CELL_SIZE)

func _process(delta):
	# Don't process game logic when paused
	if paused:
		return
	
	if current_pair == null:
		return
	
	fall_timer += delta
	if fall_timer >= fall_speed:
		fall_timer = 0.0
		move_pair_down()
	
	handle_input()

func handle_input():
	if Input.is_action_just_pressed("ui_left"):
		move_pair_horizontal(-1)
	elif Input.is_action_just_pressed("ui_right"):
		move_pair_horizontal(1)
	elif Input.is_action_just_pressed("ui_up"):
		rotate_current_pair()
	elif Input.is_action_just_pressed("ui_down"):
		fall_speed = 0.05
	
	if Input.is_action_just_released("ui_down"):
		fall_speed = 0.5

func rotate_current_pair():
	# Calculate the target rotation state (next state in 0-3 cycle)
	var target_rotation = (current_pair.rotation_state + 1) % 4
	
	# Try naive rotation (same grid_x, next rotation state)
	if can_place_pair(current_pair.grid_x, current_pair.grid_y, target_rotation):
		current_pair.rotate_pair()
		return
	
	# Try wall-kick left (grid_x - 1)
	if can_place_pair(current_pair.grid_x - 1, current_pair.grid_y, target_rotation):
		current_pair.grid_x -= 1
		current_pair.position = grid_to_world_pair(current_pair.grid_x, current_pair.grid_y)
		current_pair.rotate_pair()
		return
	
	# Try wall-kick right (grid_x + 1)
	if can_place_pair(current_pair.grid_x + 1, current_pair.grid_y, target_rotation):
		current_pair.grid_x += 1
		current_pair.position = grid_to_world_pair(current_pair.grid_x, current_pair.grid_y)
		current_pair.rotate_pair()
		return
	
	# No valid position found - block rotation (do nothing)

func move_pair_horizontal(direction: int):
	var new_x = current_pair.grid_x + direction
	# Check bounds considering horizontal orientation
	var max_x = GRID_WIDTH - 1
	if current_pair.rotation_state == 0 or current_pair.rotation_state == 2:
		max_x = GRID_WIDTH - 2  # Need space for second rune in horizontal orientations
	
	if new_x >= 0 and new_x <= max_x:
		if can_place_pair(new_x, current_pair.grid_y):
			current_pair.grid_x = new_x
			current_pair.position = grid_to_world_pair(new_x, current_pair.grid_y)

func move_pair_down():
	var new_y = current_pair.grid_y + 1
	if can_place_pair(current_pair.grid_x, new_y):
		current_pair.grid_y = new_y
		current_pair.position = grid_to_world_pair(current_pair.grid_x, new_y)
	else:
		lock_pair()

func can_place_pair(x: int, y: int, rotation: int = current_pair.rotation_state) -> bool:
	if y >= GRID_HEIGHT:
		return false
	
	var positions = get_pair_positions(x, y, rotation)
	for pos in positions:
		# Check bounds
		if pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT:
			return false
		# Check collision
		if grid[pos.y][pos.x] != null:
			return false
	return true

func get_pair_positions(x: int, y: int, rotation: int = current_pair.rotation_state) -> Array:
	var positions = []
	match rotation:
		0:  # Horizontal: rune1 left, rune2 right
			positions.append(Vector2i(x, y))
			positions.append(Vector2i(x + 1, y))
		1:  # Vertical: rune1 top, rune2 bottom
			positions.append(Vector2i(x, y))
			positions.append(Vector2i(x, y + 1))
		2:  # Horizontal: rune2 left, rune1 right
			positions.append(Vector2i(x + 1, y))
			positions.append(Vector2i(x, y))
		3:  # Vertical: rune2 top, rune1 bottom
			positions.append(Vector2i(x, y + 1))
			positions.append(Vector2i(x, y))
	return positions

func lock_pair():
	var positions = get_pair_positions(current_pair.grid_x, current_pair.grid_y)
	
	# Debug logging to detect grid position conflicts
	print("Locking rune1 at (%d, %d), rune2 at (%d, %d)" % [positions[0].x, positions[0].y, positions[1].x, positions[1].y])
	if grid[positions[0].y][positions[0].x] != null:
		print("WARNING: Grid position (%d, %d) already occupied by %s!" % [positions[0].x, positions[0].y, grid[positions[0].y][positions[0].x].get_class()])
	if grid[positions[1].y][positions[1].x] != null:
		print("WARNING: Grid position (%d, %d) already occupied by %s!" % [positions[1].x, positions[1].y, grid[positions[1].y][positions[1].x].get_class()])
	
	# Place rune1
	var rune1 = current_pair.rune1
	rune1.grid_x = positions[0].x
	rune1.grid_y = positions[0].y
	rune1.reparent(self)
	rune1.position = grid_to_world(rune1.grid_x, rune1.grid_y)
	grid[rune1.grid_y][rune1.grid_x] = rune1
	
	# Place rune2
	var rune2 = current_pair.rune2
	rune2.grid_x = positions[1].x
	rune2.grid_y = positions[1].y
	rune2.reparent(self)
	rune2.position = grid_to_world(rune2.grid_x, rune2.grid_y)
	grid[rune2.grid_y][rune2.grid_x] = rune2
	
	current_pair.queue_free()
	current_pair = null
	
	# Process matches and gravity in a loop until stable
	var changes_made = true
	while changes_made:
		changes_made = false
		
		# Check for matches
		var matches_found = check_and_remove_matches()
		if matches_found:
			changes_made = true
		
		# Apply gravity
		var pieces_fell = apply_gravity_once()
		if pieces_fell:
			changes_made = true
	
	spawn_new_pair()

func check_and_remove_matches() -> bool:
	var to_remove = []
	
	# Check horizontal matches
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH - 3):
			var match_group = check_line(x, y, 1, 0, 4)
			if match_group.size() == 4:
				to_remove.append_array(match_group)
	
	# Check vertical matches
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT - 3):
			var match_group = check_line(x, y, 0, 1, 4)
			if match_group.size() == 4:
				to_remove.append_array(match_group)
	
	# Remove duplicates and clear matched pieces
	var unique_remove = {}
	for piece in to_remove:
		unique_remove[piece] = true
	
	for piece in unique_remove.keys():
		remove_piece(piece)
	
	# Check win condition after removing matched pieces
	if unique_remove.size() > 0:
		check_win_condition()
		return true
	
	return false

func check_line(start_x: int, start_y: int, dx: int, dy: int, count: int) -> Array:
	var pieces = []
	var first_piece = grid[start_y][start_x]
	
	if first_piece == null:
		return []
	
	var first_type = get_piece_type(first_piece)
	if first_type == -1:
		return []
	
	for i in range(count):
		var x = start_x + i * dx
		var y = start_y + i * dy
		var piece = grid[y][x]
		
		if piece == null or get_piece_type(piece) != first_type:
			return []
		
		pieces.append(piece)
	
	return pieces

func get_piece_type(piece) -> int:
	if piece is Rune:
		return piece.rune_type
	elif piece is Element:
		return piece.element_type
	return -1

func remove_piece(piece):
	grid[piece.grid_y][piece.grid_x] = null
	piece.queue_free()

func apply_gravity_once() -> bool:
	var pieces_fell = false
	for y in range(GRID_HEIGHT - 2, -1, -1):
		for x in range(GRID_WIDTH):
			if grid[y][x] != null and grid[y][x] is Rune and grid[y + 1][x] == null:
				var piece = grid[y][x]
				grid[y][x] = null
				grid[y + 1][x] = piece
				piece.grid_y = y + 1
				piece.position = grid_to_world(x, y + 1)
				pieces_fell = true
	return pieces_fell

func stop_game() -> void:
	game_active = false

func get_element_count() -> int:
	var count = 0
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if grid[y][x] != null and grid[y][x] is Element:
				count += 1
	return count

func check_win_condition() -> void:
	var element_count = get_element_count()
	if element_count == 0:
		win_condition_met.emit()

func check_spawn_availability() -> bool:
	# Check if the spawn position (GRID_WIDTH / 2, 0) is available for a new pair
	# Use the existing can_place_pair() method with spawn coordinates
	var spawn_x = GRID_WIDTH / 2
	var spawn_y = 0
	return can_place_pair(spawn_x, spawn_y, 0)  # Check with default rotation (0)

## Set the paused state of the game board
func set_paused(is_paused: bool) -> void:
	paused = is_paused
