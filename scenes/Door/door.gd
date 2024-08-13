@tool
class_name Door3D
extends Node3D

const OPEN_ANIMATION = &"OPEN"

@export var locked : bool = false
@export var opened : bool = false :
	set(value):
		opened = value
		if is_inside_tree():
			if opened:
				_open_actions()
			else:
				_close_actions()

func _open_actions():
	$AnimationPlayer.play(OPEN_ANIMATION, -1, 1.0)

func _close_actions():
	$AnimationPlayer.play(OPEN_ANIMATION, -1, -3.0, true)

func open():
	if locked:
		locked_feedback()
		return
	opened = true
	opening_feedback()

func close():
	opened = false
	closing_feedback()

func toggle():
	if opened:
		close()
	else:
		open()

func lock():
	locked = true
	locking_feedback()

func unlock():
	locked = false
	unlocking_feedback()

func locked_feedback():
	$LockedStreamPlayer3D.play()

func opening_feedback():
	$OpeningStreamPlayer3D.play()

func closing_feedback():
	$ClosingStreamPlayer3D.play()

func locking_feedback():
	$LockingStreamPlayer3D.play()

func unlocking_feedback():
	$UnlockingStreamPlayer3D.play()

func _on_character_body_3d_interacting_succeeded():
	toggle()

func _ready():
	if opened: $AnimationPlayer.play(OPEN_ANIMATION, -1, 0, true)
