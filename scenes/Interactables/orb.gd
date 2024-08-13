@tool
class_name Orb
extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var held_by

func _physics_process(delta):
	if Engine.is_editor_hint():
		velocity = Vector3.ZERO
		return
	if not held_by:
		velocity += Vector3.DOWN * gravity * delta
		move_and_slide()

func hold(holding_node : Node):
	velocity = Vector3.ZERO
	held_by = holding_node

func release():
	held_by = null
	$HoldDelayTimer.start()

func can_be_held():
	return (not is_instance_valid(held_by)) and $HoldDelayTimer.is_stopped()
