extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export_range(1, 4) var player_id: int = 1

@export var base_speed: float = 200.0        # normal speed
@export var boost_speed: float = 2000.0      # speed after a double-tap
@export var double_tap_window: float = 0.3   # max seconds between taps
@export var boost_duration: float = 0.3      # how long the boost lasts
@export var acceleration: float = 3000.0     # how fast it speeds up
@export var deceleration: float = 2500.0     # how fast it slows down
@export var max_tap_hold: float = 0.2        # a press longer than this is not a tap

var _action: String = ""
var _last_tap_time: float = -1.0
var _boost_timer: float = 0.0
var _press_time: float = 0.0

# One key per player
const PLAYER_KEYS := {
	1: KEY_Q,
	2: KEY_R,
	3: KEY_U,
	4: KEY_P,
}

func _ready() -> void:
	_action = "p%d_move" % player_id
	_create_input_action()
	sprite.animation = "move"
	sprite.frame = 0

func _create_input_action() -> void:
	# Skips creation if you already defined it in Project Settings > Input Map
	if InputMap.has_action(_action):
		return
	InputMap.add_action(_action)
	var event := InputEventKey.new()
	event.physical_keycode = PLAYER_KEYS[player_id]
	InputMap.action_add_event(_action, event)

func _physics_process(delta: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0

	# Key goes down
	if Input.is_action_just_pressed(_action):
		_press_time = now

		# Second quick tap after a short first tap = boost
		if now - _last_tap_time <= double_tap_window:
			_boost_timer = boost_duration
			_last_tap_time = -1.0

	# Key released: only counts as a tap if it was short
	if Input.is_action_just_released(_action):
		if now - _press_time <= max_tap_hold:
			_last_tap_time = now
		else:
			_last_tap_time = -1.0   # long press: not a tap

	_boost_timer = max(_boost_timer - delta, 0.0)

	# Choose target speed
	var target_speed := 0.0
	if Input.is_action_pressed(_action):
		target_speed = boost_speed if _boost_timer > 0.0 else base_speed

	var rate := acceleration if target_speed > velocity.x else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)
	velocity.y = 0.0

	move_and_slide()

	_update_animation()

func _update_animation() -> void:
	if Input.is_action_pressed(_action):
		sprite.play("move")
		sprite.speed_scale = 2.0 if _boost_timer > 0.0 else 1.0
	else:
		sprite.stop()
		sprite.frame = 0
