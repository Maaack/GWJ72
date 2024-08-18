extends LevelBase

signal win_triggered

var game_won : bool = false

func _on_win_trigger_win_triggered():
	if game_won: return
	game_won = true
	win_triggered.emit()
	var tween = create_tween()
	tween.tween_property($BackgroundMusicPlayer, ^"volume_db", -70, 3.0)
	await get_tree().create_timer(3.0, false).timeout
	$EndingAudioStreamPlayer.play()
	$Player.start_floating_upwards()
