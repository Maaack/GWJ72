extends LevelBase

signal win_triggered

func _on_win_trigger_win_triggered():
	win_triggered.emit()
	await get_tree().create_timer(5.0, false).timeout
	$Player.start_floating_upwards()
