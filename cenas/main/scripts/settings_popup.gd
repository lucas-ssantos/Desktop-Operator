extends Control

# Estrutura de cena esperada:
# SettingsPopup (Control, este script)
# ├── SettingsButton (Button)
# └── Popup (PopupPanel)
#     └── VBoxContainer
#         ├── ResizeToggle (CheckButton)
#         ├── AutoSkinToggle (CheckButton)
#         └── TaskbarToggle (CheckButton)

@export var operator_path: NodePath
@export var settings_button_path: NodePath

@export_group("Taskbar Mode")
@export var taskbar_margin: float = 85.0     # bottom_margin quando "tem taskbar" está ativado
@export var no_taskbar_margin: float = 50.0  # bottom_margin quando desativado

@onready var settings_button: Button = get_node(settings_button_path)
@onready var popup: PopupPanel = $Popup
@onready var resize_toggle: CheckButton = $Popup/VBoxContainer/ResizeToggle
@onready var auto_skin_toggle: CheckButton = $Popup/VBoxContainer/AutoSkinToggle
@onready var taskbar_toggle: CheckButton = $Popup/VBoxContainer/TaskbarToggle

var operator: AnimatedSprite2D

var last_popup_hide_time: int = -1000
const REOPEN_GUARD_MS: int = 150

func _ready():
	operator = get_node(operator_path)

	var settings: Dictionary = SaveManager.load_settings()
	var resize_enabled: bool = settings.get("resize_enabled", false)
	var auto_skin_enabled: bool = settings.get("auto_skin_change_enabled", true)
	var taskbar_enabled: bool = settings.get("taskbar_mode_enabled", true)

	resize_toggle.button_pressed = resize_enabled
	auto_skin_toggle.button_pressed = auto_skin_enabled
	taskbar_toggle.button_pressed = taskbar_enabled

	_apply_resize(resize_enabled)
	operator.set_auto_skin_change_enabled(auto_skin_enabled)
	_apply_taskbar_mode(taskbar_enabled)

	popup.popup_hide.connect(_on_popup_hide)
	settings_button.pressed.connect(_on_settings_button_pressed)
	resize_toggle.toggled.connect(_on_resize_toggled)
	auto_skin_toggle.toggled.connect(_on_auto_skin_toggled)
	taskbar_toggle.toggled.connect(_on_taskbar_toggled)

func _on_popup_hide():
	last_popup_hide_time = Time.get_ticks_msec()

func _on_settings_button_pressed():
	if popup.visible:
		popup.hide()
		return

	if Time.get_ticks_msec() - last_popup_hide_time < REOPEN_GUARD_MS:
		return

	popup.popup_centered(Vector2i(220, 120))

func _on_resize_toggled(enabled: bool) -> void:
	_apply_resize(enabled)
	_save_all_settings()

func _on_auto_skin_toggled(enabled: bool) -> void:
	operator.set_auto_skin_change_enabled(enabled)
	_save_all_settings()

func _on_taskbar_toggled(enabled: bool) -> void:
	_apply_taskbar_mode(enabled)
	_save_all_settings()

func _apply_resize(enabled: bool) -> void:
	var win := get_window()
	win.borderless = not enabled
	win.unresizable = not enabled

func _apply_taskbar_mode(enabled: bool) -> void:
	operator.bottom_margin = taskbar_margin if enabled else no_taskbar_margin

func _save_all_settings() -> void:
	SaveManager.save_settings(
		resize_toggle.button_pressed,
		auto_skin_toggle.button_pressed,
		taskbar_toggle.button_pressed
	)
