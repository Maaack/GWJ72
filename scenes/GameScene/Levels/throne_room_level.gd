extends LevelBase

signal win_triggered

func _on_win_trigger_win_triggered():
	print("level win triggered")
	win_triggered.emit()
