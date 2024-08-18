extends Control

const LOCKED_DOOR_STRING : String = "Locked"
const OPEN_DOOR_STRING : String = "Open"
const EXIT_DOOR_STRING : String = "Enter the %s"
const PULL_ORB_STRING : String = "Pull Orb"
const TAKE_ORB_STRING : String = "Take Orb"
const PUT_ORB_STRING : String = "Put Orb"
const PULL_ORB_HINT_STRING : String = "You can draw the orbs of light to you."
const THROW_ORB_HINT_STRING : String = "You can throw orbs of light at your target."
const RESTART_HINT_STRING : String = "You can restart any room from the beginning."
const PROGRESS_HINT_STRING : String = "Feel free to take a break.\nYour progress is remembered."

const RMB_STRING : String = "[RMB] or [E]"
const LMB_STRING : String = "[LMB] or [Space]"
const R_STRING : String = "[R]"

@export var win_scene : PackedScene
@export var end_credits_scene : PackedScene

var _current_level
var _player_node
var _special_orb

var win_triggered : bool = false


func _ready():
	InGameMenuController.scene_tree = get_tree()

func _on_level_changed(level_path : String, _entering_door : String):
	if level_path.is_empty():
		InGameMenuController.open_menu(win_scene, get_viewport())
		return
	$LevelLoader.load_level(level_path)
	_on_player_interactable_unfocused()

func _on_level_win_triggered():
	if win_triggered : return
	win_triggered = true
	%LightMaskWorld.glow_up()
	$ScrollCreditsDelayTimer.start()

func _connect_player_node_signals():
	if not _player_node is PlayerCharacter: return
	if _player_node.has_signal(&"interactable_focused") and not _player_node.is_connected(&"interactable_focused", _on_player_interactable_focused):
		_player_node.connect(&"interactable_focused", _on_player_interactable_focused)
	if _player_node.has_signal(&"interactable_unfocused") and not _player_node.is_connected(&"interactable_unfocused", _on_player_interactable_unfocused):
		_player_node.connect(&"interactable_unfocused", _on_player_interactable_unfocused)
	if _player_node.has_signal(&"orbs_count_changed") and not _player_node.is_connected(&"orbs_count_changed", _on_player_orb_count_changed):
		_player_node.connect(&"orbs_count_changed", _on_player_orb_count_changed)

func _connect_level_node_signals():
	if _current_level.has_signal(&"level_changed") and not _current_level.is_connected("level_changed", _on_level_changed):
		_current_level.level_changed.connect(_on_level_changed)
	if _current_level.has_signal(&"win_triggered") and not _current_level.is_connected(&"win_triggered", _on_level_win_triggered):
		_current_level.win_triggered.connect(_on_level_win_triggered)
	if _current_level.has_signal(&"narration_received") and not _current_level.is_connected(&"narration_received", _on_level_narration_received):
		_current_level.narration_received.connect(_on_level_narration_received)

func _level_setup():
	win_triggered = false
	%LightMaskWorld.reset()
	$EndCredits.reset()
	$EndCredits.enabled = false
	if not $ScrollCreditsDelayTimer.is_stopped():
		$ScrollCreditsDelayTimer.stop()
	_player_node = get_tree().get_first_node_in_group(&"player")
	_special_orb = get_tree().get_first_node_in_group(&"special_orbs")
	_connect_player_node_signals()
	_connect_level_node_signals()
	$LoadingScreen.close()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_level_loader_level_loaded():
	_current_level = $LevelLoader.current_level
	await _current_level.ready
	_level_setup()

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
	%InputActionLabel.text = ""
	if locked:
		%InteractionLabel.text = LOCKED_DOOR_STRING
	elif not opened:
		%InteractionLabel.text = OPEN_DOOR_STRING
		%InputActionLabel.text = RMB_STRING
	else:
		%InteractionLabel.text = ""

func _on_player_exit_door_focused(level_name : String):
	%InputActionLabel.text = RMB_STRING
	%InteractionLabel.text = EXIT_DOOR_STRING % level_name

func _on_player_orb_focused(holding_node : Node3D):
	%InputActionLabel.text = RMB_STRING
	if holding_node:
		%InteractionLabel.text = TAKE_ORB_STRING
	else:
		%InteractionLabel.text = PULL_ORB_STRING

func _on_player_orb_holder_focused(orb_holder : OrbHolder):
	if not orb_holder.has_orbs() and _player_node.can_put_orb():
		%InputActionLabel.text = LMB_STRING
		%InteractionLabel.text = PUT_ORB_STRING
	else:
		%InputActionLabel.text = ""
		%InteractionLabel.text = ""
		
func _on_pull_orb_hint_focused():
	%InputActionLabel.text = RMB_STRING
	%InteractionLabel.text = PULL_ORB_HINT_STRING

func _on_throw_orb_hint_focused():
	%InputActionLabel.text = LMB_STRING
	%InteractionLabel.text = THROW_ORB_HINT_STRING

func _on_restart_hint_focused():
	%InputActionLabel.text = R_STRING
	%InteractionLabel.text = RESTART_HINT_STRING

func _on_progress_hint_focused():
	%InputActionLabel.text = ""
	%InteractionLabel.text = PROGRESS_HINT_STRING

func _on_player_interactable_focused(interactable_3d : Interactable3D):
	match interactable_3d.interactable_type:
		&"door":
			_on_player_door_focused(interactable_3d.interactable_node.opened, interactable_3d.interactable_node.locked)
		&"exit_door":
			_on_player_exit_door_focused(interactable_3d.interactable_node.level_name)
		&"exit_door":
			_on_player_exit_door_focused(interactable_3d.interactable_node.level_name)
		&"orb":
			_on_player_orb_focused(interactable_3d.interactable_node.held_by)
		&"orb_holder":
			_on_player_orb_holder_focused(interactable_3d.interactable_node)
		&"pull_orb_hint":
			_on_pull_orb_hint_focused()
		&"throw_orb_hint":
			_on_throw_orb_hint_focused()
		&"restart_hint":
			_on_restart_hint_focused()
		&"progress_hint":
			_on_progress_hint_focused()
	%InteractionLabel.visible = true
	%InputActionLabel.visible = true

func _on_player_interactable_unfocused():
	%InteractionLabel.visible = false
	%InputActionLabel.visible = false

func _on_player_orb_count_changed(orb_count : int):
	%CrossHairTextureRect.visible = orb_count > 0

func _process(delta):
	if is_instance_valid(_special_orb):
		%LightMaskWorld.show_sprite()
		%LightMaskWorld.set_camera_transform(_player_node.get_camera_transform())
		%LightMaskWorld.set_sprite_position(_special_orb.global_position)
	else:
		%LightMaskWorld.hide_sprite()

func _on_level_narration_received(narrated_text : String, _narrated_audio : AudioStream, timer : float = 4.0):
	if narrated_text.is_empty(): return
	%NarrationLabel.text = narrated_text
	%NarrationLabel.modulate = Color.WHITE
	%NarrationLabel.show()
	await get_tree().create_timer(timer, false).timeout
	var tween := get_tree().create_tween()
	tween.tween_property(%NarrationLabel, ^"modulate", Color.TRANSPARENT, 2.0)
	await tween.finished
	%NarrationLabel.hide()

func _on_scroll_credits_delay_timer_timeout():
	$EndCredits.enabled = true
