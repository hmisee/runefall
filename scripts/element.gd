extends Node2D
class_name Element

enum ElementType { FIRE, WATER, EARTH, AIR }

@export var element_type: ElementType = ElementType.FIRE
@export var grid_x: int = 0
@export var grid_y: int = 0

var colors = {
	ElementType.FIRE: Color.RED,
	ElementType.WATER: Color.BLUE,
	ElementType.EARTH: Color.SADDLE_BROWN,
	ElementType.AIR: Color.LIGHT_GRAY
}

func _ready():
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, 20, colors[element_type])
	draw_arc(Vector2.ZERO, 20, 0, TAU, 32, Color.WHITE, 2)

func set_element_type(type: ElementType):
	element_type = type
	queue_redraw()
