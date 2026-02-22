extends Node2D
class_name RunePair

var rune1: Rune
var rune2: Rune
var grid_x: int = 0
var grid_y: int = 0
var rotation_state: int = 0
var use_preview_data: bool = false
var preview_rune1_type: int = 0
var preview_rune2_type: int = 0

func _ready():
	rune1 = Rune.new()
	rune2 = Rune.new()
	add_child(rune1)
	add_child(rune2)
	
	if use_preview_data:
		rune1.set_rune_type(preview_rune1_type)
		rune2.set_rune_type(preview_rune2_type)
	else:
		randomize_runes()
	
	update_positions()

func randomize_runes():
	rune1.set_rune_type(randi() % 4)
	rune2.set_rune_type(randi() % 4)

func update_positions():
	match rotation_state:
		0:  # Horizontal: rune1 left, rune2 right
			rune1.position = Vector2(25, 25)
			rune2.position = Vector2(75, 25)
		1:  # Vertical: rune1 top, rune2 bottom
			rune1.position = Vector2(25, 25)
			rune2.position = Vector2(25, 75)
		2:  # Horizontal: rune2 left, rune1 right
			rune1.position = Vector2(75, 25)
			rune2.position = Vector2(25, 25)
		3:  # Vertical: rune2 top, rune1 bottom
			rune1.position = Vector2(25, 75)
			rune2.position = Vector2(25, 25)

func rotate_pair():
	rotation_state = (rotation_state + 1) % 4
	update_positions()
