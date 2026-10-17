extends Control

const FADE_TIME := 0.5
const LOADING_SCREEN := "res://src/UI/ldscrn/ldscrn.tscn"

const READY_ACTIONS: Array[StringName] = [&"P1_Ready", &"P2_Ready", &"P3_Ready", &"P4_Ready"]

const BOX_TEXTURE := preload("res://assets/Character Select/BOX.png")
const BOX_CHECK_TEXTURE := preload("res://assets/Character Select/BOX CHECK.png")

const READY_MODULATE := Color(1, 1, 1)
const NOT_READY_MODULATE := Color(0.6, 0.48, 0.5)
const TOGGLE_TIME := 0.15

const BLINK_MIN_ALPHA := 0.4
const BLINK_HALF_PERIOD := 0.5

@onready var _fade: ColorRect = $Fade
@onready var _prompt: TextureRect = $Prompt
@onready var _portraits: Array[Control] = [
	$Player1/Portrait,
	$Player2/Portrait,
	$Player3/Portrait,
	$Player4/Portrait,
]
@onready var _boxes: Array[TextureRect] = [
	$Player1/Box,
	$Player2/Box,
	$Player3/Box,
	$Player4/Box,
]

var _ready_states: Array[bool] = [false, false, false, false]
var _transitioning := false


func _ready() -> void:
	_fade.visible = true
	create_tween().tween_property(_fade, "modulate:a", 0.0, FADE_TIME)
	for portrait in _portraits:
		portrait.modulate = NOT_READY_MODULATE
	var blink := create_tween().set_loops()
	blink.tween_property(_prompt, "modulate:a", BLINK_MIN_ALPHA, BLINK_HALF_PERIOD)
	blink.tween_property(_prompt, "modulate:a", 1.0, BLINK_HALF_PERIOD)


func _unhandled_input(event: InputEvent) -> void:
	if _transitioning:
		return
	for i in READY_ACTIONS.size():
		if event.is_action_pressed(READY_ACTIONS[i]):
			_set_ready(i, not _ready_states[i])
			get_viewport().set_input_as_handled()
			return


func _set_ready(index: int, ready: bool) -> void:
	_ready_states[index] = ready
	_boxes[index].texture = BOX_CHECK_TEXTURE if ready else BOX_TEXTURE
	create_tween().tween_property(
		_portraits[index],
		"modulate",
		READY_MODULATE if ready else NOT_READY_MODULATE,
		TOGGLE_TIME
	)
	if ready and not _ready_states.has(false):
		_start_game()


func _start_game() -> void:
	_transitioning = true
	var tween := create_tween()
	tween.tween_property(_fade, "modulate:a", 1.0, FADE_TIME)
	await tween.finished
	get_tree().change_scene_to_file(LOADING_SCREEN)
