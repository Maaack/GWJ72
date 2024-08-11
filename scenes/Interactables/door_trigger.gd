class_name DoorTrigger3D
extends Node3D


signal doors_triggered

@export var doors : Array[Door3D]
var uses : int = 0
var toggled : bool = false

func _unlock_and_open_doors():
	for door in doors:
		door.unlock()
		door.open()

func trigger():
	_unlock_and_open_doors()
	uses += 1
	doors_triggered.emit()

func _on_light_trigger_body_entered(body):
	trigger()

