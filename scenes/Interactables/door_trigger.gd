class_name DoorTrigger3D
extends Node3D


signal doors_triggered

@export var doors : Array[Door3D]
@export var stay_on : bool = false
var uses : int = 0
var toggled : bool = false

func _unlock_and_open_doors():
	for door in doors:
		door.unlock()
		door.open()

func _close_and_lock_doors():
	for door in doors:
		door.close()
		door.lock()

func trigger_on():
	_unlock_and_open_doors()
	uses += 1
	doors_triggered.emit()

func trigger_off():
	if not stay_on:
		_close_and_lock_doors()

func _on_light_trigger_body_entered(body):
	trigger_on()

func _on_light_trigger_body_exited(body):
	trigger_off()
