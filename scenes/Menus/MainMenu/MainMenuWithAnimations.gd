extends MainMenu

var animation_state_machine : AnimationNodeStateMachinePlayback

func play_game():
	GameLog.game_started()
	GameState.start_new()
	super.play_game()

func intro_done():
	animation_state_machine.travel("OpenMainMenu")

func _is_in_intro():
	return animation_state_machine.get_current_node() == "Intro"

func _event_is_mouse_button_released(event : InputEvent):
	return event is InputEventMouseButton and not event.is_pressed()

func _event_skips_intro(event : InputEvent):
	return event.is_action_released("ui_accept") or \
		event.is_action_released("ui_select") or \
		event.is_action_released("ui_cancel") or \
		_event_is_mouse_button_released(event)

func _open_sub_menu(menu):
	super._open_sub_menu(menu)
	animation_state_machine.travel("OpenSubMenu")

func _close_sub_menu():
	super._close_sub_menu()
	animation_state_machine.travel("OpenMainMenu")

func _input(event):
	if _is_in_intro() and _event_skips_intro(event):
		intro_done()
	super._input(event)

func _ready():
	GameState.load_game()
	super._ready()
	animation_state_machine = $MenuAnimationTree.get("parameters/playback")

func _setup_play():
	if GameState.current == null:
		%NewGameButton.hide()
		%ContinueButton.hide()
	else:
		%PlayButton2.hide()
	super._setup_play()

func _setup_for_web():
	if OS.has_feature("web"):
		%ExitButton2.hide()


func _on_continue_button_pressed():
	GameLog.game_started()
	super.play_game()
