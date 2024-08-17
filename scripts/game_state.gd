class_name GameState
extends Node

static var starting : GameStateData = preload("res://scripts/starting_game_state.tres")
static var current : GameStateData

static func start_new():
	current = starting.duplicate()

static func get_current_level_state():
	if current:
		return current.get_current_level_state()

static func mark_level_visited():
	var level_state = get_current_level_state()
	if level_state is LevelStateData:
		level_state.visits += 1
	
		
