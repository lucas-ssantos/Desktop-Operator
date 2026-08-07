extends CanvasLayer

const DEFAULT_CHARACTER := "amiya"
const DEFAULT_LANGUAGE := "EN"

@export var operator_path: NodePath

@onready var close_button: Button = $CloseButton
@onready var character_dropdown: Control = $CharacterDropdown
@onready var skin_dropdown: Control = $SkinDropdown
@onready var language_button: OptionButton = $LanguageButton
@onready var trust_bar: ProgressBar = $TrustBar
@onready var window_edit_toggle: CheckButton = $WindowEditToggle
@onready var operator: AnimatedSprite2D = get_node(operator_path)

var current_character: String = ""
var current_skin: String = "default"
var current_language: String = DEFAULT_LANGUAGE

func _ready():
	close_button.modulate.a = 0.0
	character_dropdown.modulate.a = 0.0
	skin_dropdown.modulate.a = 0.0
	language_button.modulate.a = 0.0
	trust_bar.modulate.a = 0.0
	window_edit_toggle.modulate.a = 0.0
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	character_dropdown.mouse_filter = Control.MOUSE_FILTER_STOP
	skin_dropdown.mouse_filter = Control.MOUSE_FILTER_STOP
	language_button.mouse_filter = Control.MOUSE_FILTER_STOP
	window_edit_toggle.mouse_filter = Control.MOUSE_FILTER_STOP

	window_edit_toggle.toggled.connect(_on_window_edit_toggled)

	var win := get_window()
	win.mouse_entered.connect(_on_mouse_entered)
	win.mouse_exited.connect(_on_mouse_exited)

	character_dropdown.item_selected.connect(_on_character_selected)
	skin_dropdown.item_selected.connect(_on_skin_selected)
	language_button.item_selected.connect(_on_language_item_selected)

	var characters := CharacterManager.get_character_list()
	if characters.is_empty():
		character_dropdown.set_items(characters)
		return

	var saved := SaveManager.load_selection()
	var saved_character: String = saved.get("character", "")
	var saved_skin: String = saved.get("skin", "default")

	var initial_character: String
	if saved_character != "" and saved_character in characters:
		initial_character = saved_character
	elif DEFAULT_CHARACTER in characters:
		initial_character = DEFAULT_CHARACTER
	else:
		initial_character = characters[0]

	var skins := CharacterManager.get_skin_list(initial_character)
	var initial_skin := "default"
	if initial_character == saved_character and saved_skin in skins:
		initial_skin = saved_skin

	var initial_language := _resolve_language(initial_character, initial_skin)

	character_dropdown.set_items(characters, initial_character)
	skin_dropdown.set_items(skins, initial_skin)

	_apply_selection(initial_character, initial_skin, initial_language)

func _on_character_selected(character_name: String):
	var skins := CharacterManager.get_skin_list(character_name)
	skin_dropdown.set_items(skins, "default")

	var language := _resolve_language(character_name, "default")
	_apply_selection(character_name, "default", language)

func _on_skin_selected(skin_name: String):
	var language := _resolve_language(current_character, skin_name)
	_apply_selection(current_character, skin_name, language)

func _on_language_item_selected(index: int):
	var languages := CharacterManager.get_available_languages(current_character, current_skin)
	if index < 0 or index >= languages.size():
		return

	var language := languages[index]
	current_language = language

	operator.set_character(current_character, current_skin, current_language)
	SaveManager.save_language(current_character, current_language)

func _on_window_edit_toggled(enabled: bool) -> void:
	var win := get_window()
	win.borderless = not enabled
	win.unresizable = not enabled

func _resolve_language(character_name: String, skin_name: String) -> String:
	var available := CharacterManager.get_available_languages(character_name, skin_name)
	if available.is_empty():
		return DEFAULT_LANGUAGE

	# Personagem novo (nunca escolheu idioma) -> load_language já devolve "EN" por padrão
	var saved_language := SaveManager.load_language(character_name)
	if saved_language in available:
		return saved_language
	if DEFAULT_LANGUAGE in available:
		return DEFAULT_LANGUAGE
	return available[0]

func _apply_selection(character_name: String, skin_name: String, language: String):
	current_character = character_name
	current_skin = skin_name
	current_language = language

	operator.set_character(current_character, current_skin, current_language)
	SaveManager.save_selection(current_character, current_skin)
	SaveManager.save_language(current_character, current_language)

	trust_bar.track_character(current_character)

	var languages := CharacterManager.get_available_languages(current_character, current_skin)
	_populate_language_button(languages, current_language)

func _populate_language_button(languages: Array[String], selected: String):
	language_button.clear()
	for lang in languages:
		language_button.add_item(lang)

	if languages.is_empty():
		return

	var index := languages.find(selected)
	language_button.select(maxi(index, 0))

func _on_mouse_entered():
	create_tween().tween_property(close_button, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(skin_dropdown, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(language_button, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(trust_bar, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(window_edit_toggle, "modulate:a", 1.0, 0.15)

func _on_mouse_exited():
	create_tween().tween_property(close_button, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(skin_dropdown, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(language_button, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(trust_bar, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(window_edit_toggle, "modulate:a", 0.0, 0.15)
