extends Node2D
class_name GameBoard

const GRID_WIDTH = 8
const GRID_HEIGHT = 16
const CELL_SIZE = 50

var grid = []
var current_pair: RunePair
var fall_timer = 0.0
var fall_speed = 0.5

signal game_over

func _ready():
	initialize_grid()
	draw_boundaries()
	spawn_elements()
	spawn_new_pair()

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

func initialize_grid():
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

func spawn_new_pair():
	current_pair = RunePair.new()
	current_pair.grid_x = GRID_WIDTH / 2
	current_pair.grid_y = 0
	current_pair.position = grid_to_world(current_pair.grid_x, current_pair.grid_y)
	add_child(current_pair)

func grid_to_world(x: int, y: int) -> Vector2:
	return Vector2(x * CELL_SIZE + CELL_SIZE / 2, y * CELL_SIZE + CELL_SIZE / 2)

func _process(delta):
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
		current_pair.rotate_pair()
	elif Input.is_action_just_pressed("ui_down"):
		fall_speed = 0.05
	
	if Input.is_action_just_released("ui_down"):
		fall_speed = 0.5

func move_pair_horizontal(direction: int):
	var new_x = current_pair.grid_x + direction
	# Check bounds considering horizontal orientation
	var max_x = GRID_WIDTH - 1
	if current_pair.is_horizontal:
		max_x = GRID_WIDTH - 2  # Need space for second rune
	
	if new_x >= 0 and new_x <= max_x:
		if can_place_pair(new_x, current_pair.grid_y):
			current_pair.grid_x = new_x
			current_pair.position = grid_to_world(new_x, current_pair.grid_y)

func move_pair_down():
	var new_y = current_pair.grid_y + 1
	if can_place_pair(current_pair.grid_x, new_y):
		current_pair.grid_y = new_y
		current_pair.position = grid_to_world(current_pair.grid_x, new_y)
	else:
		lock_pair()

func can_place_pair(x: int, y: int) -> bool:
	if y >= GRID_HEIGHT:
		return false
	
	var positions = get_pair_positions(x, y)
	for pos in positions:
		# Check bounds
		if pos.x < 0 or pos.x >= GRID_WIDTH or pos.y < 0 or pos.y >= GRID_HEIGHT:
			return false
		# Check collision
		if grid[pos.y][pos.x] != null:
			return false
	return true

func get_pair_positions(x: int, y: int) -> Array:
	var positions = []
	if current_pair.is_horizontal:
		positions.append(Vector2i(x, y))
		positions.append(Vector2i(x + 1, y))
	else:
		positions.append(Vector2i(x, y))
		positions.append(Vector2i(x, y + 1))
	return positions

func lock_pair():
	var positions = get_pair_positions(current_pair.grid_x, current_pair.grid_y)
	
	# Place rune1
	var rune1 = current_pair.rune1
	rune1.grid_x = positions[0].x
	rune1.grid_y = positions[0].y
	rune1.position = grid_to_world(rune1.grid_x, rune1.grid_y)
	grid[rune1.grid_y][rune1.grid_x] = rune1
	current_pair.remove_child(rune1)
	add_child(rune1)
	
	# Place rune2
	var rune2 = current_pair.rune2
	rune2.grid_x = positions[1].x
	rune2.grid_y = positions[1].y
	rune2.position = grid_to_world(rune2.grid_x, rune2.grid_y)
	grid[rune2.grid_y][rune2.grid_x] = rune2
	current_pair.remove_child(rune2)
	add_child(rune2)
	
	current_pair.queue_free()
	current_pair = null
	
	check_matches()
	spawn_new_pair()

func check_matches():
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
