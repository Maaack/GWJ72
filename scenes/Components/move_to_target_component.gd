class_name MoveToTargetComponent
extends ComponentBase

signal move_target_changed(target_vector)
signal direction_changed(new_direction)
signal slide_collision_detected(colliding_object)

@export var character_3d : CharacterBody3D
@export var move_target : Vector3 = Vector3.ZERO :
	set(value):
		move_target = value
		move_target_changed.emit(move_target)

@export var movement_speed = 4000
@export var friction : float = 1000
@export var stopped : bool = false :
	set(value):
		stopped = value
		_update_move_sounds()

@export_group("Navigation Extras")
@export var nav_point_min_distance : float = 3
@export var move_sound_repeat_delay : float = 2.0
@export var move_sound_player_3d : AudioStreamPlayer3D

var direction : Vector3 :
	set(value):
		direction = value
		direction_changed.emit(direction)

func set_enabled(value : bool):
	super.set_enabled(value)
	_update_move_sounds()

func _can_update():
	return not stopped and enabled

func _update_move_sounds():
	if not _can_update():
		$SoundDelayTimer.stop()

func _get_movement_speed():
	return movement_speed

func _play_move_sound():
	if move_sound_player_3d == null:
		return
	if not _can_update():
		$SoundDelayTimer.stop()
	move_sound_player_3d.play()
	$SoundDelayTimer.start()

func _queue_move_sound():
	if move_sound_player_3d != null and $SoundDelayTimer.is_stopped():
		$SoundDelayTimer.start(move_sound_repeat_delay)

func _move_to_target(target : Vector3, speed : float):
	var current_direction = target.normalized()
	character_3d.velocity = current_direction * speed
	if direction != current_direction:
		direction = current_direction

func _process_movement(target : Vector3, speed : float, delta : float):
	if not _can_update() or target.is_zero_approx():
		character_3d.velocity = character_3d.velocity.move_toward(Vector3.ZERO, friction * delta)
		$SoundDelayTimer.stop()
	else:
		_move_to_target(target, speed * delta)
		_queue_move_sound()
	character_3d.move_and_slide()

func _process_impacts():
	for i in range(character_3d.get_slide_collision_count()):
		var collider = character_3d.get_slide_collision(i).get_collider()
		slide_collision_detected.emit(collider)

func _physics_process(delta):
	_process_movement(move_target, _get_movement_speed(), delta)
	if not _can_update():
		return
	_process_impacts()

func _on_sound_delay_timer_timeout():
	_play_move_sound()
