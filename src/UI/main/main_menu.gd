extends Control

const FADE_TIME := 0.5

@onready var _fade: ColorRect = $Fade
@onready var _start: TextureButton = $START
@onready var _quit: TextureButton = $QUIT
@onready var _mute: TextureButton = $MuteButton

var _transitioning := false


func _ready() -> void:
	_fade.visible = true
	create_tween().tween_property(_fade, "modulate:a", 0.0, FADE_TIME)


func _on_start_pressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	_set_buttons_disabled(true)
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	await tween.finished
	get_tree().change_scene_to_file("res://src/UI/rdyplyr/rdyplyr.tscn")


func _on_quit_pressed() -> void:
	if _transitioning:
		return
	_transitioning = true
	_set_buttons_disabled(true)
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	await tween.finished
	get_tree().quit()


func _set_buttons_disabled(disabled: bool) -> void:
	_start.disabled = disabled
	_quit.disabled = disabled
	_mute.disabled = disabled
