class_name Interactable3D
extends Node3D

signal interacting_succeeded
signal interacting_failed

@export var interactable_type : StringName
@export var interactable_node : Node3D

func interact(succeed : bool = true):
	if succeed:
		interacting_succeeded.emit()
	else:
		interacting_failed.emit()
