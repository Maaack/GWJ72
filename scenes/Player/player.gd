class_name PlayerCharacter
extends CharacterBody3D

signal died
signal orbs_count_changed(new_count : int)
signal health_changed(new_value : float)
signal stamina_changed(new_value : float, max_value : float)
signal interactable_focused(interactable_3d : Interactable3D)
signal interactable_unfocused

@export var base_mouse_sensitivity = 0.005
@export var max_stamina : float = 10.0 :
	set(value):
		max_stamina = value
		stamina_changed.emit(stamina, max_stamina)
@export var orb_attraction_strength : float
@export var special_pull_radius : float

var stamina : float :
	set(value):
		stamina = value
		stamina = min(stamina, max_stamina)
		stamina = max(stamina, 0)
		stamina_changed.emit(stamina, max_stamina)

var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 350
const AIR_FRICTION = 0.1
const AIR_SPEED = 40
const AIR_SPEED_MOD = 0.1
const STEP_DOWN_BOOST = 15.0
const RUN_SPEED_MOD = 1.5
const STAMINA_RECHARGE_MOD = 0.5
const PRIMARY_ATTACK_STAMINA_COST = 0.25
const SECONDARY_ATTACK_STAMINA_COST = 0.4

var focused_interactable
var _was_on_floor

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	var _current_speed = SPEED * delta
	var _is_running : bool = false
	if Input.is_action_pressed("run"):
		var stamina_required = delta
		if stamina > stamina_required:
			stamina -= stamina_required
			_is_running = true
	else:
		stamina += delta * STAMINA_RECHARGE_MOD
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if _is_running:
		_current_speed *= RUN_SPEED_MOD
	var horizontal_velocity = direction * _current_speed
	if is_on_floor() and direction:
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
	elif is_on_floor() and not direction:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta)
	elif not is_on_floor():
		if direction:
			horizontal_velocity *= AIR_SPEED_MOD
			horizontal_velocity.limit_length(SPEED * AIR_SPEED_MOD)
			velocity.x = move_toward(velocity.x, horizontal_velocity.x, delta)
			velocity.z = move_toward(velocity.z, horizontal_velocity.z, delta)
		else:
			velocity.x = move_toward(velocity.x, 0, delta)
			velocity.z = move_toward(velocity.z, 0, delta)
		velocity.y -= gravity * delta


	var collision = move_and_slide()
	if not collision and _was_on_floor and %StepDownRayCast3D.is_colliding():
		velocity.y -= gravity * delta * STEP_DOWN_BOOST
	_was_on_floor = is_on_floor()

func _get_dot_product(vector : Vector3) -> float: 
	var vector_a = (vector - global_position).normalized()
	var vector_b = -global_basis.z.normalized()
	return vector_a.dot(vector_b)

func get_nearest_orb_not_held():
	var orbs : Array[Orb] = %OrbAttractor.orbs
	orbs.append_array(%SpecialOrbAttractor.orbs)
	var focused_orbs : Array[Orb] = []
	if orbs.is_empty() : return
	for orb in orbs:
		if orb.held_by == %OrbHolder or orb.held_by == %SpecialOrbHolder : continue
		if _get_dot_product(orb.global_position) > 0.7:
			focused_orbs.append(orb)
	if focused_orbs.is_empty() : return
	var nearest_orb = focused_orbs.front()
	var nearest_distance_squared := INF
	for orb in focused_orbs:
		var distance_squared = orb.global_position.distance_squared_to(global_position)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			nearest_orb = orb
	return nearest_orb

func _release_closest_orb_from_holder():
	var nearest_orb = get_nearest_orb_not_held()
	if nearest_orb is Orb:
		var held_by = nearest_orb.held_by
		if held_by is OrbHolder:
			held_by.remove_orb(nearest_orb)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_sensitivity = Config.get_config(AppSettings.INPUT_SECTION, &"MouseSensitivity", 1.0)
		mouse_sensitivity *= base_mouse_sensitivity
		if not is_on_floor():
			mouse_sensitivity *= AIR_SPEED_MOD
		rotation.y -= event.relative.x * mouse_sensitivity
		$Head.rotation.x -= event.relative.y * mouse_sensitivity
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	if event.is_action_pressed("throw"):
		if %OrbHolder.has_orbs():
			var target_direction = %RangedAttackComponent.get_target_direction()
			var throwing_orb = %OrbHolder.get_closest_orb(target_direction)
			%RangedAttackComponent.attack(throwing_orb)
	if event.is_action_pressed("pickup"):
		_release_closest_orb_from_holder()
		%OrbAttractor.attract_force = orb_attraction_strength
		%SpecialOrbAttractor.attract_force = orb_attraction_strength
	elif event.is_action_released("pickup"):
		%OrbAttractor.attract_force = 0
		%SpecialOrbAttractor.attract_force = 0
	if event.is_action_pressed("interact"):
		if focused_interactable is Interactable3D:
			focused_interactable.interact()
			_update_focused_interaction()
	if event.is_action_pressed("cheat"):
		%RangedAttackComponent.attack()

func initialize():
	stamina = max_stamina
	for child in get_children():
		if child is ComponentBase or child is ComponentBase3D:
			child.initialize()

func _on_health_component_died():
	died.emit()

func _on_health_component_health_changed(new_value):
	health_changed.emit(new_value)

func _on_inventory_component_orbs_count_changed(new_count):
	orbs_count_changed.emit(new_count)

func _update_focused_interaction():
	if focused_interactable is Interactable3D:
		interactable_focused.emit(focused_interactable)

func _on_interacting_component_interactable_focused(object):
	if object is Interactable3D and focused_interactable == null:
		focused_interactable = object
		_update_focused_interaction()

func _on_interacting_component_interactable_unfocused(object):
	if object is Interactable3D and object == focused_interactable:
		focused_interactable = null
		interactable_unfocused.emit()

func give_orb(orb : Orb):
	if orb is SpecialOrb:
		%SpecialOrbHolder.give_orb(orb)
	else:
		%OrbHolder.give_orb(orb)

func get_held_orbs_count():
	return %OrbHolder.get_held_orb_count()

func get_held_special_orbs_count():
	return %SpecialOrbHolder.get_held_orb_count()

func get_camera_transform() -> Transform3D:
	return %Camera3D.global_transform

func _on_special_orb_holder_orb_held(orb):
	%SpecialOrbHolder.lock = true
	var orb_attractor_shape = %OrbAttractor/Area3D/CollisionShape3D.shape
	if orb_attractor_shape is SphereShape3D:
		orb_attractor_shape.radius = special_pull_radius

func release_special_orb():
	%SpecialOrbHolder.lock = false
	if %SpecialOrbHolder.held_orbs.is_empty(): return
	%SpecialOrbHolder.remove_orb(%SpecialOrbHolder.held_orbs.back())

func start_floating_upwards():
	gravity = -0.02
	set_deferred(&"position", position + Vector3(0, 0.1, 0))
	var tween := get_tree().create_tween()
	tween.tween_property(self, ^"gravity", 0.0, 10.0)

func is_holding_orb(orb : Orb):
	return orb in %OrbHolder.orbs or orb in %SpecialOrbHolder.orbs
