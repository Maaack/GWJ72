class_name GameState
extends Node

const STARTING_GAME_STATE_PATH = "res://scripts/starting_game_state.tres"
const SAVE_STATE_PATH = "user://current_game.res"

static var starting : GameStateData
static var current : GameStateData

static func start_new():
	if not starting is GameStateData:
		starting = load(STARTING_GAME_STATE_PATH)
	current = starting.duplicate()

static func save_game():
	if current is GameStateData:
		ResourceSaver.save(current, SAVE_STATE_PATH)

static func load_game():
	if not current is GameStateData:
		if FileAccess.file_exists(SAVE_STATE_PATH):
			current = ResourceLoader.load(SAVE_STATE_PATH)

static func get_current_level_state():
	if current:
		return current.get_current_level_state()

static func mark_level_visited():
	var level_state = get_current_level_state()
	if level_state is LevelStateData:
		level_state.visits += 1
	
		
