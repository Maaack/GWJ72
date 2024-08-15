@tool
class_name DoorTrigger3D
extends Node3D
signal doors_triggered

@export var doors : Array[Door3D]
@export var orbs : Array[Orb] :
	set(value):
		orbs = value
		if is_inside_tree():
			_updated_orbs()
@export var toggled : bool = false
@export var stay_on : bool = false

var uses : int = 0

func _updated_orbs():
	var has_orbs = !orbs.is_empty()
	if has_orbs != toggled:
		$OrbReceiver.has_orbs = has_orbs
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

func toggle_door(door : Door3D):
	if door.locked:
		door.unlock()
		door.open()
	else:
		door.close()
		door.lock()

func toggle_doors():
	for door in doors:
		toggle_door(door)

func trigger_on():
	toggle_doors()
	uses += 1
	doors_triggered.emit()

func trigger_off():
	if stay_on: return
	toggle_doors()
	
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
