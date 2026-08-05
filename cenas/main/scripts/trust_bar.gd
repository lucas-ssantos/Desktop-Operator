extends ProgressBar

# Anexa este script a uma ProgressBar (nomeada "TrustBar", filha do UI).
# No Inspector, deixe ela estreita e alta (ex: Custom Minimum Size = 20x150).
# Adiciona um Label como filho da TrustBar, nomeado "ValueLabel",
# posicionado acima da barra (ex: anchor "Center Top", position.y = -20).

@onready var value_label: Label = $ValueLabel

var tracked_character: String = ""

func _ready():
	min_value = TrustManager.MIN_TRUST
	max_value = TrustManager.MAX_TRUST
	fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP
	show_percentage = false  # usamos o Label próprio em vez do texto embutido (que mostra % e corta na barra estreita)

	TrustManager.trust_changed.connect(_on_trust_changed)

func track_character(character_name: String) -> void:
	tracked_character = character_name
	var trust := TrustManager.get_trust(character_name)
	value = trust
	_update_label(trust)

func _on_trust_changed(character_name: String, new_trust: int) -> void:
	if character_name == tracked_character:
		value = new_trust
		_update_label(new_trust)

func _update_label(trust: int) -> void:
	if value_label:
		value_label.text = "%d/%d" % [trust, int(max_value)]
