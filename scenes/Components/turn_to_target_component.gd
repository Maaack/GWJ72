class_name TurnToTargetComponent
extends ComponentBase

@export var rotation_target : Vector2 : 
	set(value):
		rotation_target = value
		rotation_angle = rotation_target.angle()
		
@export var target_nodes : Array[Node3D]
@export_range(0, 180, 0.1) var rotation_speed : float = 0.0 :
	set(value):
		rotation_speed = value
		_rotation_speed_radians = deg_to_rad(rotation_speed)
@export var locked : bool = false

var _rotation_speed_radians : float
var rotation_angle : float

func _can_update():
	return not locked and enabled

func _get_target_rotation(target_rotation_angle : float, node_rotation : float, delta : float):
	var delta_angle : float = angle_difference(node_rotation, target_rotation_angle)
	if _rotation_speed_radians > 0 and \
	abs(delta_angle) >= _rotation_speed_radians * delta:
		var _new_rotation_speed = _rotation_speed_radians * delta
		if delta_angle < 0:
			_new_rotation_speed = -_new_rotation_speed
		return node_rotation + _new_rotation_speed
	return target_rotation_angle

func _update_rotation_angle(delta : float):
	if not _can_update():
		return
	for node in target_nodes:
		node.rotation = _get_target_rotation(rotation_angle, node.rotation.y, delta)

func _physics_process(delta):
	_update_rotation_angle(delta)

func initialize():
	rotation_target = rotation_target
