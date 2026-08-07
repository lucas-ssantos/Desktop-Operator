extends Node

# Registra como Autoload em Project Settings > Globals, com o nome "SaveManager"

const SAVE_PATH := "user://save_data.cfg"

func save_selection(character_name: String, skin_name: String) -> void:
	var config := _load_config()
	config.set_value("character", "name", character_name)
	config.set_value("character", "skin", skin_name)
	config.save(SAVE_PATH)

func load_selection() -> Dictionary:
	var config := _load_config()
	return {
		"character": config.get_value("character", "name", ""),
		"skin": config.get_value("character", "skin", "default"),
	}

func save_language(character_name: String, language: String) -> void:
	var config := _load_config()
	config.set_value("languages", character_name, language)
	config.save(SAVE_PATH)

func load_language(character_name: String) -> String:
	var config := _load_config()
	return config.get_value("languages", character_name, "EN")

func save_settings(resize_enabled: bool, auto_skin_change_enabled: bool) -> void:
	var config := _load_config()
	config.set_value("settings", "resize_enabled", resize_enabled)
	config.set_value("settings", "auto_skin_change_enabled", auto_skin_change_enabled)
	config.save(SAVE_PATH)

func load_settings() -> Dictionary:
	var config := _load_config()
	return {
		"resize_enabled": config.get_value("settings", "resize_enabled", false),
		"auto_skin_change_enabled": config.get_value("settings", "auto_skin_change_enabled", true),
	}

func _load_config() -> ConfigFile:
	var config := ConfigFile.new()
	config.load(SAVE_PATH)  # se o arquivo ainda não existir, config fica vazio (usa os defaults)
	return config
