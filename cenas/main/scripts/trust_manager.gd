extends Node

# Registra como Autoload em Project Settings > Globals, com o nome "TrustManager"

signal trust_changed(character_name: String, new_trust: int)

const SAVE_PATH := "user://trust_data.cfg"
const MIN_TRUST := 0
const MAX_TRUST := 200

const PASSIVE_INTERVAL := 600.0        # 10 minutos -> +1 ponto
const PASSIVE_AMOUNT := 1

const CLICK_TRUST_COOLDOWN := 600.0    # 10 minutos entre ganhos por clique
const CLICK_TRUST_AMOUNT := 3
const SPECIAL_CLICK_TRUST_AMOUNT := 5  # quando o clique solta a animação especial

var current_active_character: String = ""
var _last_click_trust_time: Dictionary = {}  # character_name -> Time.get_ticks_msec()

var _passive_timer: Timer

func _ready():
	_passive_timer = Timer.new()
	add_child(_passive_timer)
	_passive_timer.wait_time = PASSIVE_INTERVAL
	_passive_timer.one_shot = false
	_passive_timer.timeout.connect(_on_passive_timeout)
	_passive_timer.start()

func set_active_character(character_name: String) -> void:
	current_active_character = character_name

func get_trust(character_name: String) -> int:
	var config := _load_config()
	return int(config.get_value("trust", character_name, 0))

func add_trust(character_name: String, amount: int) -> int:
	var config := _load_config()
	var current: int = int(config.get_value("trust", character_name, 0))
	var new_value: int = clampi(current + amount, MIN_TRUST, MAX_TRUST)

	config.set_value("trust", character_name, new_value)
	config.save(SAVE_PATH)

	trust_changed.emit(character_name, new_value)
	return new_value

func register_click(character_name: String, was_special: bool) -> void:
	var now := Time.get_ticks_msec()
	var last_time: int = _last_click_trust_time.get(character_name, -999999999)
	var cooldown_ms := int(CLICK_TRUST_COOLDOWN * 1000.0)

	if now - last_time < cooldown_ms:
		return  # ainda em cooldown, esse clique não rende trust

	_last_click_trust_time[character_name] = now
	var amount := SPECIAL_CLICK_TRUST_AMOUNT if was_special else CLICK_TRUST_AMOUNT
	add_trust(character_name, amount)

func _on_passive_timeout() -> void:
	if current_active_character != "":
		add_trust(current_active_character, PASSIVE_AMOUNT)

func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)
	return config
