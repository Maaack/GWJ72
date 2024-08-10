class_name MoveOrTurnComponent
extends ComponentBase

@export var navigation_agent_component_3d : NavigationAgentComponent3D :
	set(value):
		navigation_agent_component_3d = value
		if not navigation_agent_component_3d.path_position_updated.is_connected(_update_target_position):
			navigation_agent_component_3d.path_position_updated.connect(_update_target_position)
		if not navigation_agent_component_3d.path_finished.is_connected(_clear_target_position):
			navigation_agent_component_3d.path_finished.connect(_clear_target_position)

@export var move_to_target_component : MoveToTargetComponent
@export var turn_to_target_components : Array[TurnToTargetComponent]
@export var rotation_reference : Node3D
@export var move_relative_to_rotation : bool = false

@export_range(0, 180, 0.5) var move_angle_max : float = 180.0 :
	set(value):
		move_angle_max = value
		_move_angle_max_radians = deg_to_rad(move_angle_max)
@export_range(0, 180, 0.5) var turn_angle_min : float = 0.0 :
	set(value):
		turn_angle_min = value
		_turn_angle_min_radians = deg_to_rad(turn_angle_min)
@export_range(0, 180, 0.5) var turn_angle_max : float = 180.0 :
	set(value):
		turn_angle_max = value
		_turn_angle_max_radians = deg_to_rad(turn_angle_max)

var _move_angle_max_radians : float
var _turn_angle_min_radians : float
var _turn_angle_max_radians : float
var target_position : Vector3 

func _update_target_position(new_position : Vector3):
	if not enabled:
		return
	target_position = new_position

func _clear_target_position():
	target_position = Vector3.ZERO

func _update_components():
	if not enabled:
		return
	# var delta_angle = angle_difference(rotation_reference.global_rotation, target_position.angle())
	if move_to_target_component != null:
		# if abs(delta_angle) <= _move_angle_max_radians:
			#if move_relative_to_rotation:
				#move_to_target_component.move_target = Vector3.from_angle(rotation_reference.global_rotation)
			#else:
				move_to_target_component.move_target = target_position
		# else:
		#	move_to_target_component.move_target = Vector2.ZERO
	#if abs(delta_angle) <= _turn_angle_max_radians and \
	#abs(delta_angle) >= _turn_angle_min_radians:
		#for turn_to_target_component in turn_to_target_components:
			#turn_to_target_component.rotation_target = target_position
			
func _physics_process(delta):
	_update_components()

func initialize():
	move_angle_max = move_angle_max
	turn_angle_max = turn_angle_max
	turn_angle_min = turn_angle_min
	
