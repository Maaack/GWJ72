extends Control

const OPEN_DOOR_STRING : String = "Press E to open"
const CLOSE_DOOR_STRING : String = "Press E to close"
const LOCKED_DOOR_STRING : String = "Locked"
const EXIT_DOOR_STRING : String = "Press E to exit"

@export var win_scene : PackedScene
@export var lose_scene : PackedScene

var _current_level
var _player_node

func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_level_changed(level_path : String, entering_door : String):
	if level_path.is_empty():
		InGameMenuController.open_menu(win_scene, get_viewport())
		return
	$LevelLoader.load_level(level_path)
	_on_player_interactable_unfocused()

func _connect_player_node_signals():
	if not _player_node is PlayerCharacter: return
	if _player_node.has_signal(&"interactable_focused"):
		_player_node.connect(&"interactable_focused", _on_player_interactable_focused)
	if _player_node.has_signal(&"interactable_unfocused"):
		_player_node.connect(&"interactable_unfocused", _on_player_interactable_unfocused)

func _connect_level_node_signals():
	if _current_level.has_signal("level_changed"):
		_current_level.level_changed.connect(_on_level_changed)

func _on_level_loader_level_loaded():
	_current_level = $LevelLoader.current_level
	await _current_level.ready
	_player_node = get_tree().get_first_node_in_group(&"player")
	_connect_player_node_signals()
	_connect_level_node_signals()
	$LoadingScreen.close()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_level_loader_levels_finished():
	InGameMenuController.open_menu(win_scene, get_viewport())

func _on_level_loader_level_load_started():
	$LoadingScreen.reset()

func _gui_input(event):
	if event is InputEventMouse and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event.is_action_pressed("restart"):
		$LevelLoader.load_level()

func _on_player_door_focused(opened : bool, locked : bool):
	if locked:
		%InteractionLabel.text = LOCKED_DOOR_STRING
	elif opened:
		%InteractionLabel.text = CLOSE_DOOR_STRING
	else:
		%InteractionLabel.text = OPEN_DOOR_STRING

func _on_player_exit_door_focused():
	%InteractionLabel.text = EXIT_DOOR_STRING

func _on_player_interactable_focused(interactable_3d : Interactable3D):
	match interactable_3d.interactable_type:
		&"door":
			_on_player_door_focused(interactable_3d.interactable_node.opened, interactable_3d.interactable_node.locked)
		&"exit_door":
			_on_player_exit_door_focused()
	%InteractionLabel.visible = true

func _on_player_interactable_unfocused():
	%InteractionLabel.visible = false
