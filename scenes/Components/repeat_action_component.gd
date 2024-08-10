class_name RepeatActionComponent
extends ComponentBase

@export var target_components : Array[Node]
@export var target_method : StringName
@export var cooldown_time : float = 1.0
@export var start_delay_time : float = 0.0

@onready var cooldown_timer = $CooldownTimer

func set_enabled(value):
		enabled = value
		if not is_inside_tree(): return
		if enabled:
			initialize()
		else:
			cooldown_timer.stop()

func _call_target_method_on_array(_components : Array):
	for _component in _components:
		if not is_instance_valid(_component):
			push_warning("component is not valid")
			continue
		if _component.has_method(target_method) != null:
			_component.call(target_method)

func _call_method_on_components():
	if not target_components.is_empty():
		_call_target_method_on_array(target_components)

func _start_cooldown():
	cooldown_timer.start(cooldown_time)

func trigger_action():
	if not enabled:
		return
	_call_method_on_components()
	_start_cooldown()

func initialize():
	if start_delay_time > 0:
		await(get_tree().create_timer(start_delay_time, false).timeout)
	trigger_action()

func _on_timer_timeout():
	trigger_action()
