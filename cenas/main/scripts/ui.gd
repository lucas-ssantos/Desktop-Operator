extends CanvasLayer

@onready var close_button: Button = $CloseButton
@onready var character_dropdown: Control = $CharacterDropdown

func _ready():
	close_button.modulate.a = 0.0
	character_dropdown.modulate.a = 0.0
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP  # garante que clique nele continua funcionando mesmo com alpha baixo
	character_dropdown.mouse_filter = Control.MOUSE_FILTER_STOP

	var win := get_window()
	win.mouse_entered.connect(_on_mouse_entered)
	win.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	create_tween().tween_property(close_button, "modulate:a", 1.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 1.0, 0.15)

func _on_mouse_exited():
	create_tween().tween_property(close_button, "modulate:a", 0.0, 0.15)
	create_tween().tween_property(character_dropdown, "modulate:a", 0.0, 0.15)
