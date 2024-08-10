class_name RangedAttackComponent
extends AttackComponent

@export var projectile_scene : PackedScene
@export var rotation_reference : Node3D
@export var position_reference: Node3D
@export var initial_velocity : float
@export var inventory_component : InventoryComponent
@export var attack_audio_stream : AudioStreamPlayer3D

func _spawn_projectile():
	var projectile_instance : CharacterBody3D = projectile_scene.instantiate()
	if not projectile_instance:
		push_error("projectile_instance failed to instantiate.")
		return
	var spawn_direction = -rotation_reference.global_basis.z
	var level = get_tree().get_first_node_in_group(&"level")
	level.add_child(projectile_instance)
	projectile_instance.global_position = position_reference.global_position
	projectile_instance.velocity = initial_velocity * spawn_direction.normalized()
	projectile_instance.global_rotation = rotation_reference.global_rotation

func _attack_feedback():
	if not attack_audio_stream: return
	attack_audio_stream.play()

func attack():
	var has_orb = inventory_component.remove_orb()
	if has_orb:
		_spawn_projectile()
		_attack_feedback()
		
