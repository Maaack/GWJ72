@tool
class_name LightSource3D
extends Node3D

const LIGHT_UP_ANIMATION = &"LIGHT_UP"

@export var orbs : Array[Orb] :
	set(value):
		orbs = value
		if is_inside_tree():
			_updated_orbs()
@export var toggled : bool

func _updated_orbs():
	var has_orbs = !orbs.is_empty()
	if has_orbs != toggled:
		$OrbReceiver.has_orbs = has_orbs
		toggled = has_orbs
		if toggled:
			$AnimationPlayer.play(LIGHT_UP_ANIMATION)
		else:
			$AnimationPlayer.play_backwards(LIGHT_UP_ANIMATION)

func _on_light_trigger_body_entered(body):
	if body not in orbs:
		orbs.append(body)
		_updated_orbs()

func _on_light_trigger_body_exited(body):
	if body in orbs:
		orbs.erase(body)
		_updated_orbs()

func _ready():
	orbs = orbs
	$OmniLight3D.light_energy = 1 if !orbs.is_empty() else 0
