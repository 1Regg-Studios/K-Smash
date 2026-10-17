extends Control

const FADE_TIME := 0.5

@export_file("*.tscn") var next_scene_path: String = ""
@export var simulated_load_time := 3.0
@export var fill_speed := 1.2

@onready var _fill_clip: Control = $ProgressBar/FillClip
@onready var _loading_text: TextureRect = $LoadingText
@onready var _fade: ColorRect = $Fade

var _progress := 0.0
var _elapsed := 0.0
var _threaded := false


func _ready() -> void:
	create_tween().tween_property(_fade, "modulate:a", 0.0, FADE_TIME)
	_fill_clip.size.x = 0.0
	if next_scene_path != "" and ResourceLoader.exists(next_scene_path):
		_threaded = ResourceLoader.load_threaded_request(next_scene_path) == OK
	var pulse := create_tween().set_loops()
	pulse.tween_property(_loading_text, "modulate:a", 0.4, 0.5)
	pulse.tween_property(_loading_text, "modulate:a", 1.0, 0.5)


func _process(delta: float) -> void:
	_elapsed += delta
	var target := _get_target_progress()
	if _elapsed < 1.0:
		target = minf(target, 0.9)
	_progress = move_toward(_progress, target, delta * fill_speed)
	_fill_clip.size.x = $ProgressBar.size.x * _progress
	if target >= 1.0 and _progress >= 1.0:
		_finish()


func _get_target_progress() -> float:
	if not _threaded:
		return minf(_elapsed / simulated_load_time, 1.0)
	match ResourceLoader.load_threaded_get_status(next_scene_path):
		ResourceLoader.THREAD_LOAD_LOADED:
			return 1.0
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var info: Array = []
			ResourceLoader.load_threaded_get_status(next_scene_path, info)
			return info[0]
	return 0.0


func _finish() -> void:
	set_process(false)
	if _threaded:
		var tween := create_tween()
		tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
		await tween.finished
		var packed := ResourceLoader.load_threaded_get(next_scene_path) as PackedScene
		get_tree().change_scene_to_packed(packed)
