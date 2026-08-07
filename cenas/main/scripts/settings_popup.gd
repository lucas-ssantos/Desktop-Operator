extends Control

# Estrutura de cena esperada:
# SettingsPopup (Control, este script)
# ├── SettingsButton (Button)
# └── Popup (PopupPanel)
#     └── VBoxContainer
#         ├── ResizeToggle (CheckButton)
#         └── AutoSkinToggle (CheckButton)

@export var operator_path: NodePath

@onready var settings_button: Button = $SettingsButton
@onready var popup: PopupPanel = $Popup
@onready var resize_toggle: CheckButton = $Popup/VBoxContainer/ResizeToggle
@onready var auto_skin_toggle: CheckButton = $Popup/VBoxContainer/AutoSkinToggle

var operator: AnimatedSprite2D

var last_popup_hide_time: int = -1000
const REOPEN_GUARD_MS: int = 150

func _ready():
	operator = get_node(operator_path)

	var settings := SaveManager.load_settings()
	var resize_enabled: bool = settings.get("resize_enabled", false)
	var auto_skin_enabled: bool = settings.get("auto_skin_change_enabled", true)

	resize_toggle.button_pressed = resize_enabled
	auto_skin_toggle.button_pressed = auto_skin_enabled

	_apply_resize(resize_enabled)
	operator.set_auto_skin_change_enabled(auto_skin_enabled)

	popup.popup_hide.connect(_on_popup_hide)
	settings_button.pressed.connect(_on_settings_button_pressed)
	resize_toggle.toggled.connect(_on_resize_toggled)
	auto_skin_toggle.toggled.connect(_on_auto_skin_toggled)

func _on_popup_hide():
	last_popup_hide_time = Time.get_ticks_msec()

func _on_settings_button_pressed():
	if popup.visible:
		popup.hide()
		return

	if Time.get_ticks_msec() - last_popup_hide_time < REOPEN_GUARD_MS:
		return

	var button_global_pos := settings_button.global_position
	var popup_position := Vector2i(
		int(button_global_pos.x) + settings_button.size.x + 10,
		int(button_global_pos.y)
	)
	var popup_size := Vector2i(220, 90)

	popup.popup(Rect2i(popup_position, popup_size))

func _on_resize_toggled(enabled: bool) -> void:
	_apply_resize(enabled)
	SaveManager.save_settings(enabled, auto_skin_toggle.button_pressed)

func _on_auto_skin_toggled(enabled: bool) -> void:
	operator.set_auto_skin_change_enabled(enabled)
	SaveManager.save_settings(resize_toggle.button_pressed, enabled)

func _apply_resize(enabled: bool) -> void:
	var win := get_window()
	win.borderless = not enabled
	win.unresizable = not enabled
