class_name HurtBox3D
extends Area3D

const AREA_FLAG = 1
const BODY_FLAG = 2
@export_flags("Area", "Body") var _type : int = AREA_FLAG
@export var _health_component : HealthComponent
@export var _hurt_audio_player_3d : AudioStreamPlayer3D
@export var _max_damage : float = 0.0

func _get_final_damage(incoming_damage : float):
	var final_damage : float = incoming_damage
	if _max_damage != 0:
		final_damage = min(_max_damage, final_damage)
	return final_damage

func hurt(amount : float):
	var final_damage = _get_final_damage(amount)
	_health_component.damage(final_damage)
	if _hurt_audio_player_3d != null:
		_hurt_audio_player_3d.play()

func _on_area_entered(area):
	if area is HitBox3D:
		hurt(area.damage)

func _on_body_entered(_body):
	pass

func _ready():
	if _type & AREA_FLAG:
		connect("area_entered", _on_area_entered)
	if _type & BODY_FLAG:
		connect("body_entered", _on_body_entered)
		
