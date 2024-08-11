class_name DoorTrigger3D
extends Node3D
signal doors_triggered

@export var doors : Array[Door3D]
@export var stay_on : bool = false
var uses : int = 0

var light_orbs : Array 
var toggled : bool

func _updated_light_orbs():
	var has_orbs = !light_orbs.is_empty()
	if has_orbs != toggled:
		toggled = has_orbs
		if toggled:
			trigger_on()
		else:
			trigger_off()

func _unlock_and_open_doors():
	for door in doors:
		door.unlock()
		door.open()

func _close_and_lock_doors():
	for door in doors:
		door.close()
		door.lock()

func trigger_on():
	$OrbReceiver.orb_entered()
	_unlock_and_open_doors()
	uses += 1
	doors_triggered.emit()

func trigger_off():
	if stay_on: return
	$OrbReceiver.orb_exited()
	_close_and_lock_doors()
	
func _on_light_trigger_body_entered(body):
	light_orbs.append(body)
	_updated_light_orbs()

func _on_light_trigger_body_exited(body):
	light_orbs.erase(body)
	_updated_light_orbs()
