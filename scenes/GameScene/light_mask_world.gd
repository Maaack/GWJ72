extends Node3D

func move_camera(new_transform : Transform3D):
	$Camera3D.global_transform = new_transform

func move_sprite(new_position : Vector3):
	$Sprite3D.global_position = new_position

func glow_up():
	var environment : Environment = $WorldEnvironment.environment
	var tween = get_tree().create_tween()
	tween.tween_property(environment, ^"background_color", Color.WHITE, 2.0)
