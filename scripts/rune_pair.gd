extends Node2D
class_name RunePair

var rune1: Rune
var rune2: Rune
var grid_x: int = 0
var grid_y: int = 0
var is_horizontal: bool = true

func _ready():
	rune1 = Rune.new()
	rune2 = Rune.new()
	add_child(rune1)
	add_child(rune2)
	
	randomize_runes()
	update_positions()

func randomize_runes():
	rune1.set_rune_type(randi() % 4)
	rune2.set_rune_type(randi() % 4)

func update_positions():
	if is_horizontal:
		rune1.position = Vector2(25, 25)
		rune2.position = Vector2(75, 25)
	else:
		rune1.position = Vector2(25, 25)
		rune2.position = Vector2(25, 75)

func rotate_pair():
	is_horizontal = !is_horizontal
	update_positions()
