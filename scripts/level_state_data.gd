class_name LevelStateData
extends Resource

@export_file("*.tscn") var level : String
@export var orb_positions : Array[Vector3]
@export var special_orb_positions : Array[Vector3]
@export var orb_holder_states : Array[OrbHolderStateData]
@export var visits : int
