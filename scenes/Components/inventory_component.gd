class_name InventoryComponent
extends ComponentBase

signal orbs_count_changed(new_count)

@export var orbs_count : int = 1 :
	set(value):
		value = min(value, max_orbs_count)
		orbs_count = value
		orbs_count_changed.emit(orbs_count)
@export var max_orbs_count : int = 10

@export var pickup_area_3d : Area3D

func has_orbs() -> bool:
	return orbs_count > 0

func has_space() -> bool:
	return orbs_count < max_orbs_count

func add_orb() -> bool:
	if not has_space(): return false
	orbs_count += 1
	return true

func remove_orb():
	if not has_orbs(): return false
	orbs_count -= 1
	return true

func _on_body_entered(body):
	if body is Pickup:
		body.pickup()
		if body.is_in_group(&"orb"):
			add_orb()

func initialize():
	max_orbs_count = max_orbs_count
	orbs_count = orbs_count

func _ready():
	initialize()
	if pickup_area_3d:
		pickup_area_3d.body_entered.connect(_on_body_entered)
