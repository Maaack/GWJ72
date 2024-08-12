extends Node3D

const GLOW_UP_ANIMATION = &"GLOW_UP"
const GLOW_DOWN_ANIMATION = &"GLOW_DOWN"

@onready var animation_player : AnimationPlayer = $AnimationPlayer

func orb_entered():
	var current_position = 0
	var remaining_time = 0
	if animation_player.current_animation:
		current_position = animation_player.get_current_animation_position()
		remaining_time = animation_player.get_current_animation_length() - current_position
	animation_player.play(GLOW_UP_ANIMATION)
	animation_player.seek(remaining_time)

func orb_exited():
	var current_position = 0
	var remaining_time = 0
	if animation_player.current_animation:
		current_position = animation_player.get_current_animation_position()
		remaining_time = animation_player.get_current_animation_length() - current_position
	animation_player.play(GLOW_DOWN_ANIMATION)
	animation_player.seek(remaining_time)
