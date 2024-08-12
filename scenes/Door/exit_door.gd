class_name ExitDoor3D
extends Node3D

signal player_exited(new_level : String)

@export_file("*.tscn") var level_path : String

func _on_character_body_3d_interacting_succeeded():
	$ExitDelayTimer.start()
	await $ExitDelayTimer.timeout
	player_exited.emit(level_path)
