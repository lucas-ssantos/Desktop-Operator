extends AnimatedSprite2D

signal skin_changed(skin_name: String)

@export var speed: float = 60.0
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 30.0
@export var arrival_threshold: float = 4.0
@export var special_chance: float = 0.01  # 1%

@export_group("Sitting")
@export var sit_chance: float = 0.20  # 20%
@export var min_sit_time: float = 30.0
@export var max_sit_time: float = 60.0

@export_group("Sleeping")
@export var sleep_chance: float = 0.05  # 5% (o restante, 75%, vira "andar")
@export var min_sleep_time: float = 50.0
@export var max_sleep_time: float = 90.0

@export_group("Skin Rotation")
@export var min_skin_rotation_interval: float = 3600.0   # 1 hora, em segundos
@export var max_skin_rotation_interval: float = 10800.0  # 3 horas, em segundos

@onready var click_collision: CollisionShape2D = $ClickArea/CollisionShape2D
@onready var click_area: Area2D = $ClickArea
@onready var talk_timer: Node = $TalkTimer
@onready var skin_rotation_timer: Timer = $SkinRotationTimer

enum State { IDLE, WALKING, SITTING, SLEEPING, CLICKED }
var state: State = State.IDLE

var target_x: float

var current_character_name: String = ""
var current_skin_name: String = "default"
var current_language: String = "EN"

func _get_sprite_width() -> int:
	if sprite_frames == null:
		return 96
	var anim_name := "idle" if sprite_frames.has_animation("idle") else sprite_frames.get_animation_names()[0]
	var texture := sprite_frames.get_frame_texture(anim_name, 0)
	if texture == null:
		return 96
	return int(texture.get_size().x * scale.x)

func _get_half_width() -> float:
	if click_collision and click_collision.shape is RectangleShape2D:
		var rect_shape := click_collision.shape as RectangleShape2D
		return (rect_shape.size.x / 2.0) * scale.x
	return _get_sprite_width() / 2.0

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_enter_clicked()

func _ready():
	get_viewport().physics_object_picking = true  # garante que a viewport processa clique em Area2D

	TrustManager.trust_changed.connect(_on_trust_changed)
	animation_finished.connect(_on_animation_finished)

	skin_rotation_timer.one_shot = true
	skin_rotation_timer.timeout.connect(_on_skin_rotation_timeout)

	randomize()
	_enter_idle()

func set_character(character_name: String, skin_name: String = "default", language: String = "EN"):
	var character_changed := character_name != current_character_name

	current_character_name = character_name
	current_skin_name = skin_name
	current_language = language

	sprite_frames = CharacterManager.load_character_frames(character_name, skin_name)
	state = State.IDLE
	play("idle")

	TrustManager.set_active_character(character_name)
	var trust := TrustManager.get_trust(character_name)
	var audio_data := CharacterManager.load_character_audio(character_name, skin_name, language, trust)

	if character_changed:
		talk_timer.set_audio_data(audio_data)  # toca "greetings" e reinicia o ciclo de idle
	else:
		talk_timer.update_audio_data(audio_data)  # só atualiza os pools, sem cumprimento nem reset

	_restart_skin_rotation_timer()

func _restart_skin_rotation_timer() -> void:
	skin_rotation_timer.stop()

	var skins := CharacterManager.get_skin_list(current_character_name)
	if skins.size() <= 1:
		return  # só uma skin (ou nenhuma) -- não tem pra onde trocar

	skin_rotation_timer.wait_time = randf_range(min_skin_rotation_interval, max_skin_rotation_interval)
	skin_rotation_timer.start()

func _on_skin_rotation_timeout() -> void:
	var skins := CharacterManager.get_skin_list(current_character_name)
	if skins.size() <= 1:
		return

	# Prioriza sortear uma skin diferente da atual; só repete se não houver outra opção
	var other_skins := skins.filter(func(s): return s != current_skin_name)
	var candidates := other_skins if not other_skins.is_empty() else skins
	var new_skin: String = candidates[randi() % candidates.size()]

	set_character(current_character_name, new_skin, current_language)
	skin_changed.emit(new_skin)

func _on_trust_changed(character_name: String, new_trust: int) -> void:
	if character_name != current_character_name:
		return
	talk_timer.update_audio_data(
		CharacterManager.load_character_audio(current_character_name, current_skin_name, current_language, new_trust)
	)

func _enter_clicked():
	if state == State.CLICKED:
		return
	state = State.CLICKED

	var is_special := randf() < special_chance and sprite_frames.has_animation("special")
	play("special" if is_special else "click")

	talk_timer.play_click_reaction()
	TrustManager.register_click(current_character_name, is_special)

func _on_animation_finished():
	if animation == "click" or animation == "special":
		_enter_idle()

func _enter_idle():
	state = State.IDLE
	play("idle")
	var wait_time = randf_range(min_idle_time, max_idle_time)
	await get_tree().create_timer(wait_time).timeout
	if state == State.IDLE:
		_pick_next_action()

func _pick_next_action():
	var roll = randf()

	if roll < sleep_chance:
		_start_sleeping()
	elif roll < sleep_chance + sit_chance:
		_start_sitting()
	else:
		_start_walking()

func _start_walking():
	var half_width = _get_half_width()
	var window_width = get_window().size.x
	var min_x = half_width
	var max_x = window_width - half_width

	if max_x <= min_x:
		target_x = window_width / 2.0
	else:
		target_x = randf_range(min_x, max_x)

	state = State.WALKING
	play("walking")

func _start_sitting():
	state = State.SITTING
	play("sitting")
	var duration = randf_range(min_sit_time, max_sit_time)
	await get_tree().create_timer(duration).timeout
	if state == State.SITTING:
		_enter_idle()

func _start_sleeping():
	state = State.SLEEPING
	play("sleeping")
	var duration = randf_range(min_sleep_time, max_sleep_time)
	await get_tree().create_timer(duration).timeout
	if state == State.SLEEPING:
		_enter_idle()

func _process(delta):
	if state != State.WALKING:
		return

	var direction = sign(target_x - position.x)
	if direction != 0:
		flip_h = direction < 0

	position.x += direction * speed * delta

	var half_width = _get_half_width()
	position.x = clamp(position.x, half_width, get_window().size.x - half_width)

	if abs(target_x - position.x) <= arrival_threshold:
		position.x = target_x
		_enter_idle()
