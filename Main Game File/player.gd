extends CharacterBody2D
# Attach this directly to your CharacterBody2D (the one with the AnimatedSprite2D child).
# Player 1 = A (pulls left), Player 2 = L (pulls right), Enter = restart.
# Every key press advances the sprite animation by one frame. It never plays on its own.

@export var pull_anim := "pull"                 # animation to step through (uses the current one if not found)
@export var frames_per_press := 1               # frames advanced per key press
@export var animate_on_p2 := true               # also step the animation when Player 2 presses
@export var rest_after := 0.4                   # seconds without a press before returning to frame 0
@export var character_y := -70.0                # height of the character above the rope
@export var pull_per_click := 12.0
@export var recover_speed := 0.0                # > 0 makes the rope drift back to center
@export var win_distance_ratio := 0.35          # rope half-length as a fraction of screen width

var anim: AnimatedSprite2D
var rope_pos := 0.0                             # negative = P1 winning, positive = P2 winning
var p1_clicks := 0
var p2_clicks := 0
var game_over := false
var winner_text := ""
var last_press := -10.0

func _ready() -> void:
	var found := find_children("*", "AnimatedSprite2D", true, false)
	if found.size() > 0:
		anim = found[0]
		anim.autoplay = ""
		if anim.sprite_frames and anim.sprite_frames.has_animation(pull_anim):
			anim.animation = pull_anim
		anim.pause()                             # stop any autoplay
		anim.frame = 0

func _screen_center() -> Vector2:
	return get_canvas_transform().affine_inverse() * (get_viewport_rect().size / 2.0)

func _win_distance() -> float:
	return get_viewport_rect().size.x * win_distance_ratio

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if game_over:
			if event.keycode == KEY_ENTER:
				_restart()
			return
		if event.keycode == KEY_A:
			p1_clicks += 1
			rope_pos -= pull_per_click
			_step_frame()
		elif event.keycode == KEY_L:
			p2_clicks += 1
			rope_pos += pull_per_click
			if animate_on_p2:
				_step_frame()
		rope_pos = clampf(rope_pos, -_win_distance(), _win_distance())
		_check_winner()

# One key press = one animation step
func _step_frame() -> void:
	last_press = Time.get_ticks_msec() / 1000.0
	if anim == null or anim.sprite_frames == null:
		return
	var count := anim.sprite_frames.get_frame_count(anim.animation)
	if count > 0:
		anim.frame = (anim.frame + frames_per_press) % count

func _process(delta: float) -> void:
	if not game_over and recover_speed > 0.0:
		rope_pos = move_toward(rope_pos, 0.0, recover_speed * delta)

	# The character rides along the rope
	global_position = _screen_center() + Vector2(rope_pos, character_y)

	# Keep the animation frozen unless a key was pressed
	if anim:
		if anim.is_playing():
			anim.pause()
		if Time.get_ticks_msec() / 1000.0 - last_press > rest_after:
			anim.frame = 0
	queue_redraw()

func _check_winner() -> void:
	if rope_pos <= -_win_distance():
		game_over = true
		winner_text = "PLAYER 1 WINS!"
	elif rope_pos >= _win_distance():
		game_over = true
		winner_text = "PLAYER 2 WINS!"

func _restart() -> void:
	rope_pos = 0.0
	p1_clicks = 0
	p2_clicks = 0
	game_over = false
	winner_text = ""

func _draw() -> void:
	var font := ThemeDB.fallback_font
	var wd := _win_distance()
	# (0, 0) below = middle of the screen, even though this node moves
	draw_set_transform(to_local(_screen_center()), 0.0, Vector2.ONE)

	draw_line(Vector2(-wd, 0), Vector2(wd, 0), Color.SADDLE_BROWN, 6.0)
	draw_line(Vector2(0, -40), Vector2(0, 40), Color.WHITE, 2.0)
	draw_circle(Vector2(-wd, 0), 10, Color.DODGER_BLUE)
	draw_circle(Vector2(wd, 0), 10, Color.TOMATO)
	draw_circle(Vector2(rope_pos, 0), 16, Color.YELLOW)

	draw_string(font, Vector2(-wd - 100, 70), "P1 (A): %d" % p1_clicks, HORIZONTAL_ALIGNMENT_CENTER, 200, 24)
	draw_string(font, Vector2(wd - 100, 70), "P2 (L): %d" % p2_clicks, HORIZONTAL_ALIGNMENT_CENTER, 200, 24)

	if anim == null:
		draw_string(font, Vector2(-250, -120), "No AnimatedSprite2D child found!", HORIZONTAL_ALIGNMENT_CENTER, 500, 22, Color.RED)

	if game_over:
		draw_string(font, Vector2(-200, 130), winner_text, HORIZONTAL_ALIGNMENT_CENTER, 400, 36)
		draw_string(font, Vector2(-200, 170), "Press Enter to restart", HORIZONTAL_ALIGNMENT_CENTER, 400, 20)
