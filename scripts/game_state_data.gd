class_name GameStateData
extends Resource

@export_file("*.tscn") var current_level : String
@export_file("*.tscn") var entered_from : String
@export var player_orbs : int = 0
@export var player_special_orbs : int = 0
@export var entering_door_name : String

@export var level_states : Dictionary = {}

func get_current_level_state():
	if current_level.is_empty() : return
	if current_level in level_states:
		return level_states[current_level] 
	else:
		var new_level_state = LevelStateData.new()
		new_level_state.level = current_level
		level_states[current_level] = new_level_state
		return new_level_state

func get_current_level_state_orb_positions():
	var level_state = get_current_level_state()
	if level_state is LevelStateData:
		return level_state.orb_positions

func get_current_level_state_special_orb_positions():
	var level_state = get_current_level_state()
	if level_state is LevelStateData:
		return level_state.orb_positions
