class_name ComponentBase
extends Node

@export var enabled : bool = true : set = set_enabled

func set_enabled(value : bool):
	enabled = value

func initialize():
	pass # Override method in children
