extends Node

# Anexa este script a um nó (tipo "Node") chamado "TalkTimer",
# filho do Operator, com dois filhos próprios:
#   - AudioStreamPlayer (nome exato: "AudioStreamPlayer")
#   - Timer             (nome exato: "IntervalTimer")
#
# Responsabilidade única: gerenciar todo o áudio do personagem
# (greetings, talk/click, idle periódico, e as variações talk1/2/3).

@export var min_idle_audio_interval: float = 300.0  # 5 minutos, em segundos
@export var max_idle_audio_interval: float = 600.0  # 10 minutos, em segundos
@export var variation_chance: float = 0.25  # 25% de chance de tocar uma variação (talk1/2/3) no lugar do áudio base

@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer
@onready var interval_timer: Timer = $IntervalTimer

var audio_data: Dictionary = {}

func _ready():
	interval_timer.one_shot = true
	interval_timer.timeout.connect(_on_interval_timeout)

func set_audio_data(new_audio_data: Dictionary) -> void:
	audio_data = new_audio_data
	play_greetings()
	_restart_interval_timer()

func play_greetings() -> void:
	_play_single("greetings")

func play_click_reaction() -> void:
	_play_with_variation("tap")

func _on_interval_timeout() -> void:
	_play_with_variation("idle")
	_restart_interval_timer()

func _restart_interval_timer() -> void:
	interval_timer.stop()
	if audio_data.has("idle") or audio_data.has("talk_variations"):
		interval_timer.wait_time = randf_range(min_idle_audio_interval, max_idle_audio_interval)
		interval_timer.start()

func _play_single(category: String) -> void:
	if not audio_data.has(category) or audio_data[category].is_empty():
		return
	var streams: Array = audio_data[category]
	audio_player.stream = streams[randi() % streams.size()]
	audio_player.play()

func _play_with_variation(base_category: String) -> void:
	# 25% de chance: toca uma das variações (talk1/talk2/talk3), sorteada aleatoriamente.
	# Caso contrário (75%): toca o áudio base da categoria (ex: "talk" no clique, "idle" no periódico).
	if randf() < variation_chance and audio_data.has("talk_variations") and not audio_data["talk_variations"].is_empty():
		var variations: Array = audio_data["talk_variations"]
		audio_player.stream = variations[randi() % variations.size()]
		audio_player.play()
	else:
		_play_single(base_category)
