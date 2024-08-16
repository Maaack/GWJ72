@tool
class_name ExitDoor3D
extends Node3D

signal player_exited(new_level : String, door_name : String, wait_on : Signal)

const CENTER_OFFSET = Vector3(0, 1, 0)

@export_file("*.tscn") var level_path : String
@export var level_name : String
@export var entering_door_name : String = "ExitDoor"
@export var marker_position = Vector3(0, 1, 1.5)
@export var flipped : bool = false :
	set(value):
		flipped = value
		if is_inside_tree():
			var weight = (int(flipped) * 2) - 1
			$Marker3D.position.z = marker_position.z * weight


func get_start_position():
	return $Marker3D.global_position

func get_start_direction():
	var offset_centered_position = $Marker3D.global_position - (CENTER_OFFSET + global_position)
	return get_start_position() + offset_centered_position

func _on_character_body_3d_interacting_succeeded():
	$OpeningStreamPlayer3D.play()
	var await_signal = $OpeningStreamPlayer3D.finished
	if not $OpeningStreamPlayer3D.playing:
		$ExitDelayTimer.start()
		await_signal = $ExitDelayTimer.timeout
	player_exited.emit(level_path, entering_door_name, await_signal)

func _prefill_level_name():
	if level_path:
		var load_level_scene : PackedScene = load(level_path)
		var load_level_instance : LevelBase = load_level_scene.instantiate()
		if load_level_instance:
			level_name = load_level_instance.level_name

func _ready():
	flipped = flipped
	level_path = level_path
	if Engine.is_editor_hint():
		_prefill_level_name()
