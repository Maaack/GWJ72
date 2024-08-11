extends Node3D

const LIGHT_UP_ANIMATION = &"LIGHT_UP"

var light_orbs : Array 
var toggled : bool

func _updated_light_orbs():
	var has_orbs = !light_orbs.is_empty()
	if has_orbs != toggled:
		toggled = has_orbs
		if toggled:
			$AnimationPlayer.play(LIGHT_UP_ANIMATION)
		else:
			$AnimationPlayer.play_backwards(LIGHT_UP_ANIMATION)

func _on_light_trigger_body_entered(body):
	light_orbs.append(body)
	_updated_light_orbs()

func _on_light_trigger_body_exited(body):
	light_orbs.erase(body)
	_updated_light_orbs()
