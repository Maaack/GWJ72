extends MeshInstance3D

@export var rotation_speed : float = 0.0

func _process(delta):
	rotation.y += rotation_speed * delta
