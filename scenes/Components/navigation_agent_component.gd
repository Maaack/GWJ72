class_name NavigationAgentComponent3D
extends ComponentBase3D

signal path_position_updated(updated_position : Vector3)
signal path_finished

var path_position : Vector3 :
	set(value):
		path_position = value - global_position
		path_position_updated.emit(path_position)

var target_position : Vector3 :
	set(value):
		target_position = value + global_position
		if nav_agent_3d.target_position != target_position:
			nav_agent_3d.target_position = target_position
			_path_finished = false

var _path_finished : bool = false
var _physics_ready : bool = false

@onready var nav_agent_3d : NavigationAgent3D = $NavigationAgent3D

func _update_path_position():
	path_position = nav_agent_3d.get_next_path_position()

func _physics_process(delta):
	if not _physics_ready:
		_physics_ready = true
		return
	if not enabled: return
	if nav_agent_3d.is_navigation_finished():
		if not _path_finished:
			_path_finished = true
			path_finished.emit()
		return
	_update_path_position()
