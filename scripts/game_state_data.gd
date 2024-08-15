class_name GameStateData
extends Resource

@export_file("*.tscn") var current_level : String
@export_file("*.tscn") var entered_from : String
@export var player_orbs : int = 0
@export var player_special_orbs : int = 0
@export var entering_door_name : String
