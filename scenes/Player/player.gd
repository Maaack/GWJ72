extends CharacterBody3D

signal died
signal orbs_count_changed(new_count : int)
signal health_changed(new_value : float)
signal stamina_changed(new_value : float, max_value : float)

@export var base_mouse_sensitivity = 0.005
@export var max_stamina : float = 10.0 :
	set(value):
		max_stamina = value
		stamina_changed.emit(stamina, max_stamina)

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
		if $InventoryComponent.has_orbs() and stamina > PRIMARY_ATTACK_STAMINA_COST:
			stamina -= PRIMARY_ATTACK_STAMINA_COST
			%RayAttackComponent3D.attack()
	if event.is_action_pressed("alt_attack"):
		if $InventoryComponent.has_orbs() and stamina > SECONDARY_ATTACK_STAMINA_COST:
			stamina -= SECONDARY_ATTACK_STAMINA_COST
			%RangedAttackComponent.attack()

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
