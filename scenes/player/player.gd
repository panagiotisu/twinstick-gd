@icon("player.svg")
class_name Player extends CharacterBody2D

static var instance: Player

func _ready() -> void:
	assert(
		!instance and instance != self,
		"More than one Player found. There can only be one Player at most."
	)
	
	instance = self
