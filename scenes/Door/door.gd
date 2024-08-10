extends Node3D
class_name Door3D

const OPEN_ANIMATION = &"OPEN"

@export var locked : bool = false
var opened : bool = false

func open():
	if locked:
		locked_feedback()
		return
	$AnimationPlayer.play(OPEN_ANIMATION, -1, 1.0)
	opened = true
	opening_feedback()

func close():
	$AnimationPlayer.play(OPEN_ANIMATION, -1, -3.0, true)
	closing_feedback()
	opened = false

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
