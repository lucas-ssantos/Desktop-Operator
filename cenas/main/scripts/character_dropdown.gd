extends Control

signal character_selected(character_name: String)

@onready var select_button: Button = $SelectButton
@onready var popup: PopupPanel = $Popup
@onready var search_box: LineEdit = $Popup/VBoxContainer/SearchBox
@onready var item_list: ItemList = $Popup/VBoxContainer/ItemList

var all_characters: Array[String] = []

func _ready():
	all_characters = CharacterManager.get_character_list()
	_populate_list(all_characters)

	select_button.pressed.connect(_on_select_button_pressed)
	search_box.text_changed.connect(_on_search_text_changed)
	item_list.item_selected.connect(_on_item_selected)

	if not all_characters.is_empty():
		select_button.text = all_characters[0].capitalize()

func _on_select_button_pressed():
	if popup.visible:
		popup.hide()
		return
	
	search_box.clear()
	_populate_list(all_characters)
	
	var button_global_pos := select_button.global_position
	var popup_position := Vector2i(
		int(button_global_pos.x) + select_button.size.x + 10,
		int(button_global_pos.y)
	)
	var popup_size := Vector2i(220, 260)

	popup.popup(Rect2i(popup_position, popup_size))
	search_box.grab_focus()

func _on_search_text_changed(new_text: String):
	var filtered: Array[String] = all_characters.filter(
		func(name): return name.to_lower().contains(new_text.to_lower())
	)
	_populate_list(filtered)

func _populate_list(names: Array[String]):
	item_list.clear()
	for name in names:
		item_list.add_item(name.capitalize())

func _on_item_selected(index: int):
	var display_name := item_list.get_item_text(index)
	var real_name := display_name.to_lower()

	select_button.text = display_name
	popup.hide()
	character_selected.emit(real_name)
