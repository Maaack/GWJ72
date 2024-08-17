@tool
class_name OrbHolder
extends Node3D

signal orb_held(orb : Orb)
signal orb_released(orb : Orb)

@export var ring_spin : float = 0.0
@export var ring_radius : float = 0.0
@export var ring_scaling : float = 0
@export var collision_fudge : Vector3
@export var dim_orbs : bool = false
@export var lock : bool = false
@export var orbs : Array[Orb]
@export var preserve_state : bool = true

var elapsed_delta : float

var held_orbs : Array[Orb]

func add_orb(orb : Orb):
	if not orb in orbs:
		orbs.append(orb)

func remove_orb(orb : Orb):
	if lock:
		orb.global_position = global_position
		return
	if orb in orbs:
		orbs.erase(orb)
	if orb in held_orbs:
		held_orbs.erase(orb)
		orb.release()
		orb_released.emit(orb)
		_update_grab_area_size()

func has_orbs():
	return !held_orbs.is_empty()

func give_orb(orb : Orb):
	hold_orb(orb, true)
	var index = orbs.size() - 1
	var ring_offset = _get_ring_offset(index)
	orb.global_position = global_position + ring_offset

func get_closest_orb(direction : Vector3 = Vector3.FORWARD):
	if held_orbs.size() == 0: return
	var ring_position := global_position + (direction.normalized() * get_ring_radius())
	var closest_orb = held_orbs.front()
	var closest_distance_squared := INF
	for orb in held_orbs:
		var distance_squared = orb.global_position.distance_squared_to(ring_position)
		if distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_orb = orb
	remove_orb(closest_orb)
	return closest_orb

func get_orb():
	if held_orbs.size() == 0: return
	var held_orb = held_orbs.front()
	remove_orb(held_orb)
	return held_orb

func _on_area_3d_body_entered(body):
	if body is Orb:
		add_orb(body)

func _on_area_3d_body_exited(body):
	if body is Orb:
		remove_orb(body)

func _run_body_test_motion(body : PhysicsBody3D, motion : Vector3, result = null):
	if not result : result = PhysicsTestMotionResult3D.new()
	var params := PhysicsTestMotionParameters3D.new()
	params.from = body.global_transform
	params.motion = motion
	return PhysicsServer3D.body_test_motion(body.get_rid(), params, result)

func get_ring_radius() -> float:
	var count := held_orbs.size()
	if count < 2: return 0.0
	return ring_radius + (ring_scaling * (held_orbs.size() - 2)) 

func _get_ring_offset(index : int, time : float = 0.0) -> Vector3:
	var count := held_orbs.size()
	if count < 2 or index >= count: return Vector3.ZERO
	var offset = Vector3.FORWARD * get_ring_radius()
	var radians = 2*PI / count
	radians *= index
	if ring_spin > 0:
		radians += 2*PI * fmod(time, 1.0 / ring_spin) * ring_spin
	return offset.rotated(Vector3.UP, radians)

func _update_grab_area_size():
	var grab_collision_shape = $GrabArea3D/CollisionShape3D.shape
	if grab_collision_shape is CylinderShape3D:
		grab_collision_shape.radius = 0.20 + (held_orbs.size() * 0.05) 

func hold_orb(orb : Orb, force_hold = false):
	if orb.can_be_held() or force_hold:
		if not orb in orbs:
			orbs.append(orb)
		if not orb in held_orbs:
			orb.hold(self, dim_orbs)
			held_orbs.append(orb)
		orb_held.emit(orb)
		_update_grab_area_size()

func get_held_orb_count():
	return held_orbs.size()

func _physics_process(delta):
	var index = 0
	elapsed_delta += delta
	for orb in orbs:
		if orb not in held_orbs:
			hold_orb(orb)
	for held_orb in held_orbs:
		var result := PhysicsTestMotionResult3D.new()
		var target_position := global_position + _get_ring_offset(index, elapsed_delta)
		var motion := target_position - held_orb.global_position
		if _run_body_test_motion(held_orb, motion, result):
			var direction = ((index % 2) * 2) - 1
			held_orb.global_position += result.get_travel() + (direction * collision_fudge * delta)
			held_orb.velocity = result.get_remainder()
			held_orb.move_and_slide()
		else:
			held_orb.global_position = target_position
		index += 1
