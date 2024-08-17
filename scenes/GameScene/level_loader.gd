@tool
class_name LevelLoader
extends SceneLister
## Extends [SceneLister] to manage level advancement through [GameLevelLog].

signal level_load_started
signal level_loaded
signal levels_finished

## Container where the level instance will be added.
@export var level_container : Node
## Loads a level on start.
@export var auto_load : bool = true
@export_group("Debugging")
@export var force_level : String
@export var current_level : Node

var is_loading : bool = false

func get_current_level_path() -> String:
	return GameState.current.current_level if force_level.is_empty() else force_level

func _attach_level(level_resource : Resource):
	assert(level_container != null, "level_container is null")
	var instance = level_resource.instantiate()
	level_container.call_deferred("add_child", instance)
	return instance

func load_level(level_path : String = get_current_level_path()):
	if is_loading : return
	if is_instance_valid(current_level):
		current_level.queue_free()
		await current_level.tree_exited
		current_level = null
	is_loading = true
	SceneLoader.load_scene(level_path, true)
	emit_signal("level_load_started")
	await SceneLoader.scene_loaded
	is_loading = false
	current_level = _attach_level(SceneLoader.get_resource())
	emit_signal("level_loaded")

func _ready():
	if Engine.is_editor_hint():
		# Text files get a `.remap` extension added on export.
		_refresh_files()
	if auto_load:
		load_level()
