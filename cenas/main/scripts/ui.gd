extends CanvasLayer

@onready var close_button: Button = $CloseButton

func _ready():
	close_button.modulate.a = 0.0
	close_button.mouse_filter = Control.MOUSE_FILTER_STOP  # garante que clique nele continua funcionando mesmo com alpha baixo

	var win := get_window()
	win.mouse_entered.connect(_on_mouse_entered)
	win.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	create_tween().tween_property(close_button, "modulate:a", 1.0, 0.15)

func _on_mouse_exited():
	create_tween().tween_property(close_button, "modulate:a", 0.0, 0.15)
