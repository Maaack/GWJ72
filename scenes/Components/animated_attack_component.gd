class_name AnimatedAttackComponent
extends AttackComponent

const DEFAULT_ATTACK_ANIMATION_NAME = &"ATTACK"
const RESET_ANIMATION_NAME = &"RESET"

@export var attack_animation : StringName = DEFAULT_ATTACK_ANIMATION_NAME
@export var animation_player : AnimationPlayer

func attack():
	if not animation_player is AnimationPlayer:
		push_warning("animation_player is not set.")
		return
	animation_player.play(attack_animation)

func stop():
	if not animation_player is AnimationPlayer:
		push_warning("animation_player is not set.")
		return
	animation_player.stop()
