class_name InteractingComponent
extends ComponentBase

signal interactable_focused(object)
signal interactable_unfocused(object)

@export var ray_cast : RayCast3D
var current_interactable

func _physics_process(delta):
		var _collider = ray_cast.get_collider()
		var last_interactable = current_interactable
		if _collider != null and _collider is Interactable3D:
			current_interactable = _collider
		else:
			current_interactable = null
		if last_interactable != current_interactable:
			if last_interactable != null:
				interactable_unfocused.emit(last_interactable)
			if current_interactable != null:
				interactable_focused.emit(current_interactable)
