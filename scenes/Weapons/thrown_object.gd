extends CharacterBody3D

@export var object_pickup_scene : PackedScene
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _drop_object():
	if not object_pickup_scene: return
	var object_pickup_instance = object_pickup_scene.instantiate()
	object_pickup_instance.position = position
	object_pickup_instance.position.y = 0.0
	var level = get_tree().get_first_node_in_group(&"level")
	level.add_child(object_pickup_instance)

func _physics_process(delta):
	velocity += Vector3.DOWN * gravity * delta
	var collided = move_and_slide()
	%HitCollisionShape3D.disabled = !collided
	if collided and is_on_floor():
		_drop_object()
		queue_free()
