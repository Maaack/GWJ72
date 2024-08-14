@tool
class_name Orb
extends CharacterBody3D

@export var friction : float = 1.0
@export var dimmed : bool = false
var held_by : Node
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if Engine.is_editor_hint():
		velocity = Vector3.ZERO
		return
	if not held_by:
		if not is_on_floor():
			velocity += Vector3.DOWN * gravity * delta
		else:
			if velocity.length_squared() > 0.1:
				velocity += -velocity * delta * friction
			else:
				velocity = Vector3.ZERO
		move_and_slide()

func hold(holding_node : Node, dim : bool = false):
	velocity = Vector3.ZERO
	held_by = holding_node
	if dim:
		dimmed = true
		$GlowAnimationPlayer.play_backwards(&"LIGHT_UP")

func release():
	velocity = Vector3.ZERO
	held_by = null
	if dimmed:
		dimmed = false
		$GlowAnimationPlayer.play(&"LIGHT_UP")

	if $HoldDelayTimer.is_inside_tree():
		$HoldDelayTimer.start()

func can_be_held():
	return (not is_instance_valid(held_by)) and $HoldDelayTimer.is_stopped()

func _ready():
	held_by = held_by
	$OmniLight3D.light_energy = 1 if !dimmed else 0
	$OmniLight3D.visible = !dimmed
