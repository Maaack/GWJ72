class_name ComponentBase3D
extends Node3D

@export var enabled : bool = true : set = set_enabled

func set_enabled(value : bool):
	enabled = value

func initialize():
	pass # Override method in children
