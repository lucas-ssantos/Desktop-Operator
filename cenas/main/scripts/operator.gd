extends AnimatedSprite2D

@export var speed: float = 60.0
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 30.0
@export var arrival_threshold: float = 4.0
@export var strip_padding: int = 40  # folga vertical pra animações que saltam
@export var vertical_offset_ratio: float = 5.5

enum State { IDLE, WALKING, CLICKED }
var state: State = State.IDLE

var win: Window
var target_x: float
var screen_width: int

func _ready():
	win = get_window()
	win.borderless = true
	win.transparent_bg = true
	win.always_on_top = true
	win.unresizable = true

	var usable_rect: Rect2i

	if OS.get_name() == "Windows":
		usable_rect = DisplayServer.screen_get_usable_rect()
	else:
		var full_size = DisplayServer.screen_get_size()
		usable_rect = Rect2i(Vector2i.ZERO, full_size)

	screen_width = usable_rect.size.x
	var strip_height = _get_sprite_height() + strip_padding
	var floor_y = usable_rect.position.y + usable_rect.size.y - strip_height

	win.size = Vector2i(screen_width, strip_height)
	position.y = strip_height / vertical_offset_ratio

	position.y = strip_height / 5.5

	animation_finished.connect(_on_animation_finished)

	randomize()
	_enter_idle()

func _get_sprite_height() -> int:
	if sprite_frames == null:
		return 96
	var anim_name := "idle" if sprite_frames.has_animation("idle") else sprite_frames.get_animation_names()[0]
	var texture := sprite_frames.get_frame_texture(anim_name, 0)
	return 96 if texture == null else int(texture.get_size().y * scale.y)

func _get_sprite_width() -> int:
	if sprite_frames == null:
		return 96
	var anim_name := "idle" if sprite_frames.has_animation("idle") else sprite_frames.get_animation_names()[0]
	var texture := sprite_frames.get_frame_texture(anim_name, 0)
	return 96 if texture == null else int(texture.get_size().x * scale.x)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var half_w = _get_sprite_width() / 2.0
		var half_h = _get_sprite_height() / 2.0
		var local_click = event.position  # coordenadas locais da janela, já que é o único viewport

		if abs(local_click.x - position.x) <= half_w and abs(local_click.y - position.y) <= half_h:
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
		_pick_new_target()

func _pick_new_target():
	var min_x = screen_width * 0.1
	var max_x = screen_width * 0.9
	target_x = randf_range(min_x, max_x)
	state = State.WALKING
	play("walking")

func _process(delta):
	if state != State.WALKING:
		return

	var direction = sign(target_x - position.x)
	if direction != 0:
		flip_h = direction < 0

	position.x += direction * speed * delta

	if abs(target_x - position.x) <= arrival_threshold:
		position.x = target_x
		_enter_idle()
