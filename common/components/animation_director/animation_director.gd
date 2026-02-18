@icon("animation_director.svg")
class_name AnimationDirector extends Node

enum Cardinal { UP, UPRIGHT, RIGHT, DOWNRIGHT, DOWN }
enum FacePattern { LINEAR, SQUARE, RHOMBUS, HEXAGON, OCTAGON }

class DirectionalAnimationKey:
	var animation_state_name: String
	var cardinal: Cardinal

@export_group(GlobalStrings.ExportGroupNames.COMPONENTS)
@export var _animation_player: AnimationPlayer
@export var _visuals: Node2D

@export_group(GlobalStrings.ExportGroupNames.PROPERTIES)
@export var _face_pattern: FacePattern = FacePattern.LINEAR

var _directional_animation_map: Dictionary[DirectionalAnimationKey, StringName] = {}
var _string_to_cardinal: Dictionary[String, Cardinal] = {
	"up"        : Cardinal.UP,
	"upright"   : Cardinal.UPRIGHT,
	"right"     : Cardinal.RIGHT,
	"downright" : Cardinal.DOWNRIGHT,
	"down"      : Cardinal.DOWN
}
const DELIMITER: String = "."

var speed_scale: float:
	get:
		return _animation_player.speed_scale
	set(value):
		_animation_player.speed_scale = value

func _ready() -> void:
	_populate_directional_animation_map()

func play(animation: StringName) -> void:
	assert(
		not animation.contains(DELIMITER),
		"Directionless animation " + animation + " of " + owner.name + " must not contain " + 
		DELIMITER  + " delimiters."
	)
	_animation_player.play(animation)

func play_directional(animation_state: StringName, face_direction: Vector2) -> void:
	_visuals.scale.x = -1 if face_direction.x < 0 else 1
	
	var directional_animation_key := DirectionalAnimationKey.new()
	directional_animation_key.animation_state_name = animation_state
	directional_animation_key.cardinal = _get_cardinal_from_vector(face_direction)
	
	var directional_animation_name: StringName = _directional_animation_map[directional_animation_key]
	_animation_player.play(directional_animation_name)

func _populate_directional_animation_map() -> void:
	for raw_animation_name in _animation_player.get_animation_list():
		var parts: PackedStringArray = raw_animation_name.split(DELIMITER)
		
		assert(
			parts.size() == 2,
			"There should be exactly one " +  DELIMITER  + " delimiter in animation name " + 
			raw_animation_name + " of " + owner.name + "." 
		)
		
		var animation_state_name := StringName(parts[0])
		var cardinal_suffix: String = parts[1]
		
		assert(
			_string_to_cardinal.has(cardinal_suffix),
			"Unknown direction suffix " + cardinal_suffix + " in animation name " +
			raw_animation_name + " of " + owner.name + "."
		)
		
		var cardinal: Cardinal = _string_to_cardinal[cardinal_suffix]
		
		var directional_animation_key := DirectionalAnimationKey.new()
		directional_animation_key.animation_state_name = animation_state_name
		directional_animation_key.cardinal = cardinal
		
		_directional_animation_map[directional_animation_key] = StringName(raw_animation_name)

func _get_cardinal_from_vector(face_direction: Vector2) -> Cardinal:
	var angle_degrees := rad_to_deg(face_direction.angle())
	var angle_degrees_wrapped := fmod(angle_degrees + 360, 360)
	
	match _face_pattern:
		FacePattern.LINEAR:
			return Cardinal.RIGHT
		FacePattern.SQUARE:
			return _get_cardinal_from_square_pattern(angle_degrees_wrapped)
		FacePattern.RHOMBUS:
			return _get_cardinal_from_rhombus_pattern(angle_degrees_wrapped)
		FacePattern.HEXAGON:
			return _get_cardinal_from_hexagon_pattern(angle_degrees_wrapped)
		FacePattern.OCTAGON:
			return _get_cardinal_from_octagon_pattern(angle_degrees_wrapped)
		_:
			return Cardinal.RIGHT
			
func _get_cardinal_from_square_pattern(angle_degrees_wrapped: float) -> Cardinal:
	if angle_degrees_wrapped >= 0 and angle_degrees_wrapped < 180:
		return Cardinal.DOWNRIGHT
	else: # angle_degrees_wrapped >= 180 and angle_degrees_wrapped < 360:
		return Cardinal.UPRIGHT
	
func _get_cardinal_from_rhombus_pattern(angle_degrees_wrapped: float) -> Cardinal:
	if angle_degrees_wrapped >= 315 or angle_degrees_wrapped < 45:
		return Cardinal.RIGHT
	elif angle_degrees_wrapped >= 45 and angle_degrees_wrapped < 135:
		return Cardinal.DOWN
	elif angle_degrees_wrapped >= 135 and angle_degrees_wrapped < 225:
		return Cardinal.RIGHT
	else: # angle_degrees_wrapped >= 225 and angle_degrees_wrapped < 315:
		return Cardinal.UP

func _get_cardinal_from_hexagon_pattern(angle_degrees_wrapped: float) -> Cardinal:
	if angle_degrees_wrapped >= 0 and angle_degrees_wrapped < 60:
		return Cardinal.DOWNRIGHT
	elif angle_degrees_wrapped >= 60 and angle_degrees_wrapped < 120:
		return Cardinal.DOWN
	elif angle_degrees_wrapped >= 120 and angle_degrees_wrapped < 180:
		return Cardinal.DOWNRIGHT
	elif angle_degrees_wrapped >= 180 and angle_degrees_wrapped < 240:
		return Cardinal.UPRIGHT
	elif angle_degrees_wrapped >= 240 and angle_degrees_wrapped < 300:
		return Cardinal.UP
	else: # angle_degrees_wrapped >= 300 and angle_degrees_wrapped < 360:
		return Cardinal.UPRIGHT

func _get_cardinal_from_octagon_pattern(angle_degrees_wrapped: float) -> Cardinal:
	if angle_degrees_wrapped >= 337.5 or angle_degrees_wrapped < 22.5:
		return Cardinal.RIGHT
	elif angle_degrees_wrapped >= 22.5 and angle_degrees_wrapped < 67.5:
		return Cardinal.DOWNRIGHT
	elif angle_degrees_wrapped >= 67.5 and angle_degrees_wrapped < 112.5:
		return Cardinal.DOWN
	elif angle_degrees_wrapped >= 112.5 and angle_degrees_wrapped < 157.5:
		return Cardinal.DOWNRIGHT
	elif angle_degrees_wrapped >= 157.5 and angle_degrees_wrapped < 202.5:
		return Cardinal.RIGHT
	elif angle_degrees_wrapped >= 202.5 and angle_degrees_wrapped < 247.5:
		return Cardinal.UPRIGHT
	elif angle_degrees_wrapped >= 247.5 and angle_degrees_wrapped < 292.5:
		return Cardinal.UP
	else: # angle_degrees_wrapped >= 292.5 and angle_degrees_wrapped < 337.5:
		return Cardinal.UPRIGHT
