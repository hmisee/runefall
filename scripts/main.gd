extends Node2D

@onready var game_board = $GameBoard

func _ready():
	game_board.game_over.connect(_on_game_over)

func _on_game_over():
	print("Game Over!")
