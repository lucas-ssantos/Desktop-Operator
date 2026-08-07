extends Control

signal item_selected(item_name: String)

@onready var select_button: Button = $"../../TopLeftGroup/SkinButton"
@onready var popup: PopupPanel = $Popup
@onready var search_box: LineEdit = $Popup/VBoxContainer/SearchBox
@onready var item_list: ItemList = $Popup/VBoxContainer/ItemList

var all_items: Array[String] = []

var last_popup_hide_time: int = -1000
const REOPEN_GUARD_MS: int = 150

func _ready():
	popup.popup_hide.connect(_on_popup_hide)
	select_button.pressed.connect(_on_select_button_pressed)
	search_box.text_changed.connect(_on_search_text_changed)
	item_list.item_selected.connect(_on_item_selected)

func set_items(items: Array[String], default_selected: String = ""):
	all_items = items.duplicate()
	_populate_list(all_items)

	if default_selected != "" and default_selected in all_items:
		select_button.text = default_selected.capitalize()
	elif not all_items.is_empty():
		select_button.text = all_items[0].capitalize()
	else:
		select_button.text = "—"

func _on_popup_hide():
	last_popup_hide_time = Time.get_ticks_msec()

func _on_select_button_pressed():
	if popup.visible:
		popup.hide()
		return

	if Time.get_ticks_msec() - last_popup_hide_time < REOPEN_GUARD_MS:
		return

	search_box.clear()
	_populate_list(all_items)

	popup.popup_centered(Vector2i(220, 260))
	search_box.grab_focus()

func _on_search_text_changed(new_text: String):
	var filtered: Array[String] = all_items.filter(
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
	item_selected.emit(real_name)
