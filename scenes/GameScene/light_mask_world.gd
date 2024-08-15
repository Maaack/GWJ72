extends Node3D

func set_camera_transform(new_transform : Transform3D):
	$Camera3D.global_transform = new_transform

func set_sprite_position(new_position : Vector3):
	$Sprite3D.global_position = new_position

func hide_sprite():
	$Sprite3D.hide()

func show_sprite():
	$Sprite3D.show()

func glow_up():
	var environment : Environment = $WorldEnvironment.environment
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite3D, ^"pixel_size", 0.2, 10.0)
	tween.parallel().tween_property(environment, ^"background_color", Color.WHITE, 10.0)
