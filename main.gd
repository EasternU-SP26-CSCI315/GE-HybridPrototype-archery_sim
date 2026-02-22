extends Node2D

enum Phase { SET_PEAK, ANIMATING, STOPPED }
var phase: Phase = Phase.SET_PEAK

const START_POS: Vector2 = Vector2(50, 600)

var peak_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO

var t: float = 0.0
var speed: float = 0.5  # Full traversal per second

var score: int = 0
var Hscore: int = 0
var score_multiplier: int = 1

var shots: int = 0

var last_y: float = 0.0

var signal_triggered: bool = false

var lvl1: bool = true
var lvl2: bool = false
var lvl3: bool = false

var motion: float = 5
var ymotion: float = 5
var target_direction: float = -1.0
var target_ydirection: float = -1.0

@onready var sprite: StaticBody2D = $StaticBody2D
@onready var score_label: Label = $Control/score_label
@onready var static_body_2d_2: StaticBody2D = $StaticBody2D2
@onready var high_score: Label = $Control/High_score
@onready var shots_label: Label = $Control/shots

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_stream_player_2d_2: AudioStreamPlayer2D = $AudioStreamPlayer2D2







func _ready() -> void:
	sprite.global_position = START_POS
	$StaticBody2D2/Area2D.Hit_outer_signal.connect(_on_hit_outer_signal)
	$StaticBody2D2/Area2D.Hit_inner_signal.connect(_on_hit_inner_signal)
	$StaticBody2D2/Area2D.Hit_bullseye_signal.connect(_on_Hit_bullseye_signal)
	score_label.text = str(score)
	high_score.text = str(Hscore) + " with " + str(shots) + " shots."
	shots_label.text = str(shots)
func _on_hit_outer_signal():
	if signal_triggered:
		return
	audio_stream_player_2d_2.play(0.22)
	signal_triggered = true
	print("hit a outer ring")	
	phase = Phase.STOPPED
	t = 0.0
	score += (1 * score_multiplier)
	score_label.text = str(score)

func _on_hit_inner_signal():
	if signal_triggered:
		return
	audio_stream_player_2d_2.play(0.22)
	signal_triggered = true
	print("hit a inner nring")
	phase = Phase.STOPPED
	t = 0.0
	score += (4 * score_multiplier)
	score_label.text = str(score)
	
func _on_Hit_bullseye_signal():
	if signal_triggered:
		return
	audio_stream_player_2d.play()
	signal_triggered = true
	print("hit a bullseye")
	phase = Phase.STOPPED
	t = 0.0
	score += (10 * score_multiplier)
	score_label.text = str(score)
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos: Vector2 = get_global_mouse_position()

		match phase:
			Phase.SET_PEAK:
				sprite.rotation = -0.3
				peak_pos = mouse_pos
				# Mirror the start point across the peak's X to get the end point.
				# End shares the same Y as start, X is reflected: end.x = 2 * peak.x - start.x
				end_pos = Vector2(2.0 * peak_pos.x - START_POS.x, START_POS.y)
				print("Peak: ", peak_pos, " | End calculated: ", end_pos)
				t = 0.0
				sprite.global_position = START_POS
				shots += 1
				shots_label.text = str(shots)
				phase = Phase.ANIMATING

			Phase.ANIMATING:
				# Click during animation resets so the user can pick a new peak
				sprite.global_position = START_POS
				t = 0.0
				phase = Phase.SET_PEAK
				sprite.rotation = -0.36
				print("Reset! Click to set new peak.")
				
			Phase.STOPPED:
				sprite.global_position = START_POS
				sprite.rotation = -0.27
				t =0.0
				phase = Phase.SET_PEAK
				signal_triggered = false


func _process(delta: float) -> void:
	if phase == Phase.ANIMATING:
		t += delta * speed
		if last_y > sprite.position.y :
			sprite.rotation = -0.3
		elif last_y < sprite.position.y:
			sprite.rotation = 0.3

		last_y = sprite.position.y
		
		
		if t >= 1.0:
			t = 1.0
			sprite.global_position = end_pos
			phase = Phase.SET_PEAK
			return

		sprite.global_position = _quadratic_bezier(START_POS, peak_pos, end_pos, t)
		
	if lvl2:
		static_body_2d_2.position.x += motion * target_direction
		if 	static_body_2d_2.position.x >= 1100:
			target_direction = -1.0
		elif static_body_2d_2.position.x <= 500:
			target_direction = 1.0
			
	if lvl3:
		static_body_2d_2.position.x += motion * target_direction
		if 	static_body_2d_2.position.x >= 1100:
			target_direction = -1.0
		elif static_body_2d_2.position.x <= 500:
			target_direction = 1.0
		
		static_body_2d_2.position.y += ymotion * target_ydirection
		if static_body_2d_2.position.y <= 300:
			target_ydirection = 1.0
		elif static_body_2d_2.position.y >= 553:
			target_ydirection = -1.0


func _quadratic_bezier(p0: Vector2, vertex: Vector2, p2: Vector2, t_val: float) -> Vector2:
	# Converts the visual vertex/peak into the correct Bézier control point
	var control: Vector2 = (4.0 * vertex - p0 - p2) / 2.0
	var u: float = 1.0 - t_val
	return u * u * p0 + 2.0 * u * t_val * control + t_val * t_val * p2


func _on_lvl_1_pressed() -> void:
	if lvl1:
		return
	lvl1 = true
	lvl2 = false
	lvl3 = false
	static_body_2d_2.position.x = 1053
	static_body_2d_2.position.y = 553

func _on_lvl_2_pressed() -> void:
	if lvl2:
		return
	score_multiplier = 2
	lvl1 = false
	lvl2 = true
	lvl3 = false
	static_body_2d_2.position.y = 553
	
func _on_lvl_3_pressed() -> void:
	if lvl3:
		return 
	score_multiplier = 3
	lvl1 = false
	lvl2 = false
	lvl3 = true
	static_body_2d_2.position.x = 500
	static_body_2d_2.position.y = 553


func _on_reset_pressed() -> void:
	lvl1 = true
	lvl3 = false
	lvl2 = false
	
	static_body_2d_2.position.x = 1053
	static_body_2d_2.position.y = 553

	if score >= Hscore:
		Hscore = score
		high_score.text = str(Hscore) + " with " + str(shots) + " shots."
		
	score = 0
	score_label.text = str(score)
	score_multiplier = 1
	
	shots = 0
	shots_label.text = str(shots)
