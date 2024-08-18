class_name NarrationZone
extends Node3D

@export_multiline var narration_text : String
@export var narration_audio : AudioStream
@export var narration_timer : float = 4.0

var seen : bool = false


func _on_area_3d_body_entered(body):
	if body is PlayerCharacter:
		if seen : return
		seen = true
		body.narrated_area_entered.emit(narration_text, narration_audio, narration_timer)
