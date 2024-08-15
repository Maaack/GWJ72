@tool
extends Node3D

const GLOW_UP_ANIMATION = &"GLOW_UP"
const GLOW_DOWN_ANIMATION = &"GLOW_DOWN"

@onready var animation_player : AnimationPlayer = $AnimationPlayer

@export var has_orbs : bool = false :
	set(value):
		var _changed = value != has_orbs
		has_orbs = value
		if _changed and is_inside_tree():
			orb_feedback()

func orb_feedback():
	if has_orbs:
		orb_entered_animation()
	else:
		orb_exited_animation()

func orb_entered_animation():
	var current_position = 0
	var remaining_time = 0
	if animation_player.current_animation:
		current_position = animation_player.get_current_animation_position()
		remaining_time = animation_player.get_current_animation_length() - current_position
	animation_player.play(GLOW_UP_ANIMATION)
	animation_player.seek(remaining_time)

func orb_exited_animation():
	var current_position = 0
	var remaining_time = 0
	if animation_player.current_animation:
		current_position = animation_player.get_current_animation_position()
		remaining_time = animation_player.get_current_animation_length() - current_position
	animation_player.play(GLOW_DOWN_ANIMATION, -1 , 2.0)
	animation_player.seek(remaining_time)

func instant_update():
	orb_feedback()
	animation_player.seek(animation_player.current_animation_length)

func _ready():
	has_orbs = has_orbs
	instant_update()
