class_name SpinningPickup
extends Pickup

@export var rotation_rate : float = 1.0

func _process(delta):
	var total_rotation_rate = delta * rotation_rate
	rotation.y += total_rotation_rate
