class_name TargetNavigationComponent
extends ComponentBase

@export var navigation_agent_component_3d : NavigationAgentComponent3D :
	set(value):
		navigation_agent_component_3d = value
		if not navigation_agent_component_3d.path_position_updated.is_connected(_update_target_to_navigation_position):
			navigation_agent_component_3d.path_position_updated.connect(_update_target_to_navigation_position)

@export var target_components : Array[ComponentBase]
@export var target_components_3d : Array[ComponentBase3D]
@export var target_variable : StringName

func _update_target_variable_on_array(_components : Array, new_position : Vector3):
	for _component in _components:
		if _component.get(target_variable) != null:
			_component.set(target_variable, new_position)

func _update_target_to_navigation_position(new_position : Vector3):
	if not enabled:
		return
	if not target_components.is_empty():
		_update_target_variable_on_array(target_components, new_position)
	if not target_components_3d.is_empty():
		_update_target_variable_on_array(target_components_3d, new_position)
