class_name CheckLOSComponent3D
extends ComponentBase3D

signal los_updated(new_position)

@export var target_group_name : StringName
@export_flags_3d_physics var collision_mask : int
@export_range(0, 10, 0.1, "or_greater") var update_time : float = 0.5

@onready var update_timer_node : Timer = $UpdateTimer

var los_position : Vector3 :
	set(value):
		los_position = value
		los_updated.emit(los_position)

var has_los : bool = false
var _update_los : bool = true

func _get_target_intersect_ray():
	var target_node = get_tree().get_first_node_in_group(target_group_name)
	var space_state = get_world_3d().direct_space_state
	var target_position = target_node.global_position
	var target_collision_shape : Node3D =  target_node.get_node("CollisionShape3D")
	if target_collision_shape:
		target_position = target_collision_shape.global_position
	var query = PhysicsRayQueryParameters3D.create(global_position, target_position, collision_mask)
	return space_state.intersect_ray(query)

func _result_is_los_to_target(result : Dictionary):
	return not result.is_empty() and result.collider.is_in_group(target_group_name)

func _update_los_to_target():
	var result = _get_target_intersect_ray()
	has_los = _result_is_los_to_target(result)
	if has_los:
		los_position = result.position - global_position

func _physics_process(delta):
	if enabled and _update_los:
		_update_los_to_target()
		_update_los = false
		update_timer_node.start(update_time)

func _on_update_timer_timeout():
	_update_los = true
