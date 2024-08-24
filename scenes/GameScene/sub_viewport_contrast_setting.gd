extends SubViewportContainer


@export var contrast_key : StringName = "Contrast"
@export var video_section : StringName = AppSettings.VIDEO_SECTION
@export var color_palettes : Array[Texture] = []

func _ready():
	var contrast_setting = Config.get_config(video_section, contrast_key, 0)
	if material is ShaderMaterial:
		material.set_shader_parameter("color_palette", color_palettes[contrast_setting])
	var _timer = Timer.new()
	_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_timer)
	_timer.start(0.25)
	while is_inside_tree():
		await _timer.timeout
		var check_setting = Config.get_config(video_section, contrast_key, contrast_setting)
		if check_setting != contrast_setting and material is ShaderMaterial:
			contrast_setting = check_setting
			material.set_shader_parameter("color_palette", color_palettes[contrast_setting])
	_timer.queue_free()
