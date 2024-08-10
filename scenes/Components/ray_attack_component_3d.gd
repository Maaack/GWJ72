class_name RayAttackComponent3D
extends ComponentBase3D

@export var damage : float = 1.0
@export var attack_duration : float = 0.1
@export var attack_refresh : float = 0.0
@export var attack_audio_stream : AudioStreamPlayer3D

var hit_colliders : Array = []
var is_attacking : bool = false
var is_attack_ready : bool = true 

func _attack_feedback():
	if not attack_audio_stream: return
	attack_audio_stream.play()

func _ready_attack():
	if not is_attack_ready: return
	if attack_refresh <= 0: return
	is_attack_ready = false
	await get_tree().create_timer(attack_refresh, false).timeout
	is_attack_ready = true

func attack():
	if not is_attack_ready: return
	if is_attacking: return
	is_attacking = true
	$RayCast3D.enabled = true
	_attack_feedback()
	_ready_attack()
	await get_tree().create_timer(attack_duration, false).timeout
	$RayCast3D.enabled = false
	hit_colliders.clear()
	is_attacking = false

func _physics_process(delta):
	if not is_attacking: return
	if not $RayCast3D.is_colliding(): return
	var collider = $RayCast3D.get_collider()
	# Only hit once per attack
	if collider in hit_colliders: return
	hit_colliders.append(collider)
	if collider is HurtBox3D:
		collider.hurt(damage)
