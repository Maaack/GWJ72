extends Node3D

signal level_changed(new_level : String)

func _change_level(new_level : StringName):
	level_changed.emit(new_level)

func _connect_exit_door(exit_door : ExitDoor3D):
	if not exit_door.player_exited.is_connected(_change_level):
		exit_door.player_exited.connect(_change_level)

func _connect_exit_doors():
	for node in get_children():
		if node is ExitDoor3D:
			_connect_exit_door(node)

func _ready():
	_connect_exit_doors()
