extends Node3D


var orbs : Array[Orb]
@export var attract_force : float = 0
@export var attracts_unholdable : bool = false
@export var add_friction_mod : float = 0.0

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
		if add_friction_mod > 0:
			orb.velocity.x = move_toward(orb.velocity.x, 0, delta * add_friction_mod)
			orb.velocity.y = move_toward(orb.velocity.y, 0, delta * add_friction_mod)
		var acceleration = relative_position * attract_force * delta
		orb.velocity += acceleration
