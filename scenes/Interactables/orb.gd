@tool
class_name Orb
extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var held : bool = false

func _physics_process(delta):
	if not held:
		velocity += Vector3.DOWN * gravity * delta
		move_and_slide()

func hold():
	held = true

func release():
	held = false
	$HoldDelayTimer.start()

func can_be_held():
	return (not held) and $HoldDelayTimer.is_stopped()
