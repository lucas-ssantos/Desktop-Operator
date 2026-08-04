extends AnimatedSprite2D

@export var speed: float = 60.0
@export var min_idle_time: float = 2.0
@export var max_idle_time: float = 30.0
@export var arrival_threshold: float = 4.0

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

	# altura vem do tamanho de design do projeto (o mesmo 1920x550 que você vê no editor 2D)
	var window_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

	var usable_rect: Rect2i
	if OS.get_name() == "Windows":
		usable_rect = DisplayServer.screen_get_usable_rect()
	else:
		usable_rect = Rect2i(Vector2i.ZERO, DisplayServer.screen_get_size())

	screen_width = usable_rect.size.x
	var floor_y = usable_rect.position.y + usable_rect.size.y - window_height

	win.size = Vector2i(screen_width, window_height)
	win.position = Vector2i(usable_rect.position.x, floor_y)

	# NADA de mexer em position.x/position.y do personagem aqui —
	# fica exatamente onde você deixou no editor

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
