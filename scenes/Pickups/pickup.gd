class_name Pickup
extends CharacterBody3D

signal picked_up

var is_picked_up : bool = false

@export var spawn_offset : Vector3 = Vector3.ZERO
@export var is_draggable : bool = true :
	set(value):
		is_draggable = value
		set_physics_process(is_draggable)

var is_dragged : bool = false
var friction : float = 300

func _physics_process(delta):
	if not is_dragged:
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)
		if get_position_delta().length_squared() < 1:
			velocity = Vector3.ZERO
	move_and_slide()

func _process_pickup():
	emit_signal("picked_up")
	queue_free()

func pickup():
	if is_picked_up:
		return
	is_picked_up = true
	_process_pickup()

func _ready():
	position += spawn_offset
	is_draggable = is_draggable
