extends Node2D

var timer = 60
@export var visual : Label 
var memory = "120"

func _ready() -> void:
	visual.text = memory
	
func _process(delta: float) -> void:
	timer = timer - delta
	if (str(floor(timer)) != memory):
		memory = str(floor(timer)).pad_decimals(0)
		visual.text = memory
	if(timer <= 0):
		endGame()

func endGame():
	get_tree().quit()
