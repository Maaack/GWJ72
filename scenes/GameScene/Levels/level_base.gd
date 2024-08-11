extends Node3D

signal level_won
signal level_lost

func _lose_level():
	level_lost.emit()

func _win_level():
	level_won.emit()

func _connect_exit_door(exit_door : ExitDoor3D):
	if not exit_door.player_exited.is_connected(_win_level):
		exit_door.player_exited.connect(_win_level)

func _connect_exit_doors():
	for node in get_children():
		if node is ExitDoor3D:
			_connect_exit_door(node)

func _ready():
	_connect_exit_doors()
