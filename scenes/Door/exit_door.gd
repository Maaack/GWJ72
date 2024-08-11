class_name ExitDoor3D
extends Node3D

signal player_exited

func _on_character_body_3d_interacting_succeeded():
	$ExitDelayTimer.start()
	await $ExitDelayTimer.timeout
	player_exited.emit()
