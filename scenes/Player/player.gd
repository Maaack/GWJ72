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

var stamina : float :
	set(value):
		stamina = value
		stamina = min(stamina, max_stamina)
		stamina = max(stamina, 0)
		stamina_changed.emit(stamina, max_stamina)

var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 5.5
const JUMP_VELOCITY = 4.5
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
	get_nearest_orb_not_held()
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
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
	var _current_speed = SPEED
	if _is_running:
		_current_speed *= RUN_SPEED_MOD
	if direction:
		velocity.x = direction.x * _current_speed
		velocity.z = direction.z * _current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	var collision = move_and_slide()
	if not collision and _was_on_floor and %StepDownRayCast3D.is_colliding():
		velocity.y -= gravity * delta * STEP_DOWN_BOOST
	_was_on_floor = is_on_floor()

func _get_dot_product(vector : Vector3) -> float: 
	var vector_a = vector.normalized()
	var vector_b = -global_basis.z.normalized()
	return vector_a.dot(vector_b)

func get_nearest_orb_not_held():
	var orbs : Array[Orb] = %OrbAttractor.orbs
	var focused_orbs : Array[Orb] = []
	if orbs.is_empty() : return
	for orb in orbs:
		if orb.held_by == %OrbHolder : continue
		if _get_dot_product(orb.global_position) > 0.9:
			focused_orbs.append(orb)
	if focused_orbs.is_empty() : return
	var closest_orb = focused_orbs.front()
	var closest_distance_squared := INF
	for orb in focused_orbs:
		var distance_squared = orb.global_position.distance_squared_to(global_position)
		if distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_orb = orb
	return closest_orb

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_sensitivity = Config.get_config(AppSettings.INPUT_SECTION, &"MouseSensitivity", 1.0)
		mouse_sensitivity *= base_mouse_sensitivity
		rotation.y -= event.relative.x * mouse_sensitivity
		$Head.rotation.x -= event.relative.y * mouse_sensitivity
		$Head.rotation.x = clamp($Head.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		mouse_relative_x = clamp(event.relative.x, -50, 50)
		mouse_relative_y = clamp(event.relative.y, -50, 10)
	if event.is_action_pressed("attack"):
		if %OrbHolder.has_orbs():
			var target_direction = %RangedAttackComponent.get_target_direction()
			var throwing_orb = %OrbHolder.get_closest_orb(target_direction)
			%RangedAttackComponent.attack(throwing_orb)
	if event.is_action_pressed("alt_attack"):
		%OrbAttractor.attract_force = orb_attraction_strength
	elif event.is_action_released("alt_attack"):
		%OrbAttractor.attract_force = 0
	if event.is_action_pressed("interact"):
		%RangedAttackComponent.attack()
		#if focused_interactable is Interactable3D:
			#focused_interactable.interact()
			#_update_focused_interaction()

func initialize():
	stamina = max_stamina
	for child in get_children():
		if child is ComponentBase or child is ComponentBase3D:
			child.initialize()

func get_inventory() -> InventoryComponent:
	return $InventoryComponent

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
