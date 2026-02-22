extends Node2D
class_name Rune

enum RuneType { FIRE, WATER, EARTH, AIR }

@export var rune_type: RuneType = RuneType.FIRE
@export var grid_x: int = 0
@export var grid_y: int = 0

var colors = {
	RuneType.FIRE: Color.RED,
	RuneType.WATER: Color.BLUE,
	RuneType.EARTH: Color.SADDLE_BROWN,
	RuneType.AIR: Color.LIGHT_GRAY
}

func _ready():
	queue_redraw()

func _draw():
	# Draw a square for runes
	var size = 18
	draw_rect(Rect2(-size, -size, size * 2, size * 2), colors[rune_type])
	draw_rect(Rect2(-size, -size, size * 2, size * 2), Color.WHITE, false, 2)

func set_rune_type(type: RuneType):
	rune_type = type
	queue_redraw()
