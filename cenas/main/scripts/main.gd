extends Node

# Anexa este script ao nó raiz da cena (ex: "Main").
# Responsabilidade única: configurar e posicionar a janela do jogo na tela.
# Não sabe nada sobre o personagem, animações ou clique.

func _ready():
	
	print(CharacterManager)
	
	var win := get_window()
	win.borderless = false
	win.transparent_bg = true
	win.always_on_top = true
	win.unresizable = false

	# altura/largura vêm do tamanho de design do projeto
	# (o mesmo valor que você vê no editor 2D, em Project Settings > Display > Window)
	var window_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")
	var window_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")

	var usable_rect: Rect2i
	if OS.get_name() == "Windows":
		usable_rect = DisplayServer.screen_get_usable_rect()
	else:
		usable_rect = Rect2i(Vector2i.ZERO, DisplayServer.screen_get_size())

	var floor_y = usable_rect.position.y + usable_rect.size.y - window_height

	win.size = Vector2i(window_width, window_height)
	win.position = Vector2i(usable_rect.position.x, floor_y)
