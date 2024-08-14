extends Node3D

signal level_changed(new_level : String, entering_door : String)

@export var orb_scene : PackedScene

func _change_level(new_level : String, entering_door : String):
	_save_player_state()
	_save_level_state(new_level, entering_door)
	level_changed.emit(new_level, entering_door)

func _connect_exit_door(exit_door : ExitDoor3D):
	if not exit_door.player_exited.is_connected(_change_level):
		exit_door.player_exited.connect(_change_level)

func _connect_exit_doors():
	for node in get_children():
		if node is ExitDoor3D:
			_connect_exit_door(node)

func _move_player_to_door():
	var door_name = GameState.current.entering_door_name
	if door_name.is_empty(): return
	var door_node = find_child(door_name)
	if door_node is ExitDoor3D:
		$Player.global_position = door_node.get_start_position()
		var direction = door_node.get_start_direction()
		$Player.global_transform = $Player.global_transform.looking_at(direction)

func _give_player_orbs():
	var orb_count = GameState.current.player_orbs
	for i in range(orb_count):
		var orb_instance = orb_scene.instantiate()
		add_child(orb_instance)
		$Player.give_orb(orb_instance)

func _save_level_state(level_path : String, entering_door : String):
	GameState.current.current_level = level_path
	GameState.current.entering_door_name = entering_door

func _save_player_state():
	GameState.current.player_orbs = $Player.get_held_orbs_count()

func _ready():
	_move_player_to_door()
	_give_player_orbs()
	_connect_exit_doors()
