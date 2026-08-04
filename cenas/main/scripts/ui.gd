extends CanvasLayer

@export var operator_path: NodePath

@onready var close_button: Button = $CloseButton
@onready var character_dropdown: Control = $CharacterDropdown
@onready var skin_dropdown: Control = $SkinDropdown
@onready var operator: AnimatedSprite2D = get_node(operator_path)

var current_character: String = ""
var current_skin: String = "default"

func _ready():
	close_button.modulate.a = 0.0
	character_dropdown.modulate.a = 0.0
	skin_dropdown.modulate.a = 0.0
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP
	character_dropdown.mouse_filter = Control.MOUSE_FILTER_STOP
	skin_dropdown.mouse_filter = Control.MOUSE_FILTER_STOP

	var win := get_window()
	win.mouse_entered.connect(_on_mouse_entered)
	win.mouse_exited.connect(_on_mouse_exited)

	character_dropdown.item_selected.connect(_on_character_selected)
	skin_dropdown.item_selected.connect(_on_skin_selected)

	var characters := CharacterManager.get_character_list()
	character_dropdown.set_items(characters)

	if not characters.is_empty():
		_on_character_selected(characters[0])

func _on_character_selected(character_name: String):
	current_character = character_name
	current_skin = "default"

	var skins := CharacterManager.get_skin_list(character_name)
	skin_dropdown.set_items(skins, "default")

	operator.set_character(current_character, current_skin)

func _on_skin_selected(skin_name: String):
	current_skin = skin_name
	operator.set_character(current_character, current_skin)

func _on_mouse_entered():
	create_tween().tween_property(close_button, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(skin_dropdown, "modulate:a", 1.0, 0.15)

func _on_mouse_exited():
	create_tween().tween_property(close_button, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(skin_dropdown, "modulate:a", 0.0, 0.15)
