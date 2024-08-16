class_name LevelBase
extends Node3D

signal level_changed(new_level : String, entering_door : String)

@export var level_name : String
@export var orb_scene : PackedScene
@export var special_orb_scene : PackedScene

func _change_level(new_level : String, entering_door : String):
	_save_player_state()
	_save_orb_holder_states()
	_save_orb_states()
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

func _give_player_special_orbs():
	var special_orb_count = GameState.current.player_special_orbs
	for i in range(special_orb_count):
		var special_orb_instance = special_orb_scene.instantiate()
		add_child(special_orb_instance)
		$Player.give_orb(special_orb_instance)

func _save_level_state(level_path : String, entering_door : String):
	GameState.current.current_level = level_path
	GameState.current.entering_door_name = entering_door

func _save_player_state():
	GameState.current.player_orbs = $Player.get_held_orbs_count()
	GameState.current.player_special_orbs = $Player.get_held_special_orbs_count()

func _get_level_held_orbs():
	var held_orbs : Array[Orb] = []
	var orb_holders : Array[Node] = get_tree().get_nodes_in_group(&"orb_holders")
	for orb_holder in orb_holders:
		if orb_holder is OrbHolder:
			held_orbs.append_array(orb_holder.held_orbs)
	return held_orbs

func _save_orb_holder_states():
	var level_state = GameState.get_current_level_state()
	if level_state is LevelStateData:
		level_state.orb_holder_states.clear()
		var orb_holders : Array[Node] = get_tree().get_nodes_in_group(&"orb_holders")
		for orb_holder in orb_holders:
			if orb_holder is OrbHolder:
				if not orb_holder.preserve_state : continue
				var orb_holder_state := OrbHolderStateData.new()
				orb_holder_state.node_path = orb_holder.get_path()
				orb_holder_state.orb_count = orb_holder.held_orbs.size()
				level_state.orb_holder_states.append(orb_holder_state)

func _save_orb_states():
	var orb_positions : Array[Vector3]= []
	var special_orb_positions : Array[Vector3]= []
	var held_orbs = _get_level_held_orbs()
	for child in get_children():
		if child is Orb:
			if child in held_orbs: continue
			if child is SpecialOrb:
				special_orb_positions.append(child.global_position)
			else:
				orb_positions.append(child.global_position)
	var level_state = GameState.get_current_level_state()
	if level_state is LevelStateData:
		level_state.orb_positions = orb_positions
		level_state.special_orb_positions = special_orb_positions

func _remove_all_loose_orbs():
	for child in get_children():
		if child is Orb:
			child.queue_free()

func _update_orb_holders(orb_holder_states : Array[OrbHolderStateData]):
	for orb_holder_state in orb_holder_states:
		var orb_holder_node = get_node(orb_holder_state.node_path)
		if orb_holder_node is OrbHolder:
			var orb_difference = orb_holder_state.orb_count - orb_holder_node.orbs.size()
			if orb_difference > 0:
				for i in range(orb_difference):
					var orb_instance : Node3D = orb_scene.instantiate()
					add_child(orb_instance)
					orb_holder_node.give_orb(orb_instance)
			elif orb_difference < 0:
				for i in range(-orb_difference):
					var orb : Orb = orb_holder_node.orbs.back()
					orb_holder_node.remove_orb(orb)
					orb.queue_free()

func _reset_orb_holder_containers():
	var orb_holder_containers : Array[Node] = get_tree().get_nodes_in_group(&"orb_holder_containers")
	for orb_holder_container in orb_holder_containers:
		if orb_holder_container.has_method(&"reset_state"):
			orb_holder_container.reset_state()

func _spawn_orbs_at_positions(orb_positions : Array[Vector3]):
	for orb_position in orb_positions:
		var orb_instance : Node3D = orb_scene.instantiate()
		add_child(orb_instance)
		orb_instance.global_position = orb_position

func _spawn_special_orbs_at_positions(orb_positions : Array[Vector3]):
	for orb_position in orb_positions:
		var orb_instance : Node3D = special_orb_scene.instantiate()
		add_child(orb_instance)
		orb_instance.global_position = orb_position

func _load_orbs_from_level_state():
	var level_state = GameState.get_current_level_state()
	if level_state is LevelStateData:
		if level_state.orb_positions != null:
			_update_orb_holders(level_state.orb_holder_states)
			_spawn_orbs_at_positions(level_state.orb_positions)
			_spawn_special_orbs_at_positions(level_state.special_orb_positions)

func _ready():
	_move_player_to_door()
	_give_player_orbs()
	_give_player_special_orbs()
	_load_orbs_from_level_state()
	_reset_orb_holder_containers()
	_connect_exit_doors()
	$Player.initialize()
