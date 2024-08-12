class_name GameState
extends Node

static var starting : GameStateData = preload("res://scripts/starting_game_state.tres")
static var current : GameStateData

static func start_new():
	current = starting.duplicate()
