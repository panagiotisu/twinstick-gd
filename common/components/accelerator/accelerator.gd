@icon("accelerator.svg")
class_name Accelerator extends Node

@onready var _moveable_entity: CharacterBody2D = owner

@export_group("Parameters")
@export var max_speed: float = 80.0
@export var acceleration_coefficient: float = 300.0

var velocity: Vector2 = Vector2.ZERO
var speed:
	get():
		return velocity.length()

func accelerate_towards(direction: Vector2, delta: float) -> void:
	var target_velocity: Vector2 = direction * max_speed
	accelerate_to_velocity(target_velocity, delta)

func accelerate_to_velocity(target_velocity: Vector2, delta: float) -> void:
	var speed_delta: float = delta * acceleration_coefficient
	velocity = velocity.move_toward(target_velocity, speed_delta)
	
	apply_velocity()

func apply_velocity() -> void:
	_moveable_entity.velocity = velocity
	_moveable_entity.move_and_slide()
