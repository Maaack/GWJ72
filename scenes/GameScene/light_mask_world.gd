extends Node3D

@onready var initial_pixel_size = $Sprite3D.pixel_size
var tween

@export var glow_up_duration : float = 20.0

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
	tween = create_tween()
	tween.tween_property($Sprite3D, ^"pixel_size", 0.2, glow_up_duration)
	tween.parallel().tween_property(environment, ^"background_color", Color.WHITE, glow_up_duration)

func reset():
	if tween is Tween:
		tween.stop()
	var environment : Environment = $WorldEnvironment.environment
	$Sprite3D.pixel_size = initial_pixel_size
	environment.background_color = Color.BLACK
		
