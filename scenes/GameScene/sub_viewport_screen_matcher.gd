extends SubViewportContainer

func _set_subviewport_to_screen_size():
	for child in get_children():
		if child is SubViewport:
			child.size = get_window().size

func _ready():
	_set_subviewport_to_screen_size()
