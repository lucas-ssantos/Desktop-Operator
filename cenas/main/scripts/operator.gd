extends AnimatedSprite2D

@export var speed: float = 60.0
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 30.0
@export var arrival_threshold: float = 4.0

@export_group("Sitting")
@export var sit_chance: float = 0.20  # 20%
@export var min_sit_time: float = 30.0
@export var max_sit_time: float = 60.0

@export_group("Sleeping")
@export var sleep_chance: float = 0.05  # 5% (o restante, 75%, vira "andar")
@export var min_sleep_time: float = 50.0
@export var max_sleep_time: float = 90.0

@onready var click_collision: CollisionShape2D = $ClickArea/CollisionShape2D

enum State { IDLE, WALKING, SITTING, SLEEPING, CLICKED }
var state: State = State.IDLE

var target_x: float

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
	# fallback, caso o shape não esteja configurado ainda
	return _get_sprite_width() / 2.0

func _ready():
	animation_finished.connect(_on_animation_finished)
	randomize()
	_enter_idle()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_enter_clicked()

func _enter_clicked():
	if state == State.CLICKED:
		return
	state = State.CLICKED
	play("click")

func _on_animation_finished():
	if animation == "click":
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

	# trava contra as bordas da janela, usando a largura real do personagem
	var half_width = _get_half_width()
	position.x = clamp(position.x, half_width, get_window().size.x - half_width)

	if abs(target_x - position.x) <= arrival_threshold:
		position.x = target_x
		_enter_idle()
