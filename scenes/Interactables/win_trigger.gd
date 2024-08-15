class_name WinTrigger3D
extends Node3D
signal win_triggered

@export var orbs : Array[Orb] :
	set(value):
		orbs = value
		if is_inside_tree():
			_updated_orbs()
@export var toggled : bool = false

func _updated_orbs():
	var has_orbs = !orbs.is_empty()
	if has_orbs != toggled:
		$OrbReceiver.has_orbs = has_orbs
		toggled = has_orbs
		if toggled:
			win_triggered.emit()

func _on_light_trigger_body_entered(body):
	if body not in orbs:
		orbs.append(body)
		_updated_orbs()

func _on_light_trigger_body_exited(body):
	if body in orbs:
		orbs.erase(body)
		_updated_orbs()

func init_state():
	$OrbReceiver.has_orbs = orbs.size() > 0
	$OrbReceiver.instant_update()

func _ready():
	orbs = orbs
	%OrbHolder.orbs = orbs.duplicate()
	init_state()

func init_orbs_from_holder():
	orbs = %OrbHolder.orbs.duplicate()

func reset_state():
	init_orbs_from_holder()
	init_state()

func _on_player_detector_area_3d_body_entered(body):
	if body is PlayerCharacter:
		body.release_special_orb()
