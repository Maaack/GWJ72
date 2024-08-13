extends Node3D


var orbs : Array[Orb]
@export var attract_force : float = 0
@export var attracts_unholdable : bool = false

func add_orb(orb : Orb):
	orbs.append(orb)

func remove_orb(orb : Orb):
	orbs.erase(orb)

func _on_area_3d_body_entered(body):
	if body is Orb:
		add_orb(body)

func _on_area_3d_body_exited(body):
	if body is Orb:
		remove_orb(body)

func _physics_process(delta):
	for orb in orbs:
		if not orb.can_be_held() and not attracts_unholdable:
			continue
		var relative_position = global_position - orb.global_position
		relative_position = relative_position.normalized()
		var acceleration = relative_position * attract_force * delta
		orb.velocity += acceleration
