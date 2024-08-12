extends Node3D


var orbs : Array[CharacterBody3D]
@export var attract_force : float = 0

func _on_area_3d_body_entered(body):
	orbs.append(body)

func _on_area_3d_body_exited(body):
	orbs.erase(body)

func _physics_process(delta):
	for orb in orbs:
		var relative_position = global_position - orb.global_position
		relative_position = relative_position.normalized()
		var acceleration = relative_position * attract_force * delta
		orb.global_position = global_position
