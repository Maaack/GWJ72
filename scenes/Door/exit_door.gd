@tool
class_name ExitDoor3D
extends Node3D

signal player_exited(new_level : String)

const CENTER_OFFSET = Vector3(1, 1, 0)

@export_file("*.tscn") var level_path : String
@export var entering_door_name : String = "ExitDoor"
@export var flipped : bool = false :
	set(value):
		flipped = value
		if is_inside_tree():
			var weight = (int(flipped) * 2) - 1
			$Marker3D.position.z = marker_position.z * weight

@onready var marker_position = $Marker3D.position

func get_start_position():
	return $Marker3D.global_position

func get_start_direction():
	var offset_centered_position = $Marker3D.position - CENTER_OFFSET
	return $Marker3D.global_position - offset_centered_position

func _on_character_body_3d_interacting_succeeded():
	$ExitDelayTimer.start()
	await $ExitDelayTimer.timeout
	player_exited.emit(level_path, entering_door_name)

func _ready():
	flipped = flipped
