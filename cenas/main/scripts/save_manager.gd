extends Node

# Registra como Autoload em Project Settings > Globals, com o nome "SaveManager"

const SAVE_PATH := "user://save_data.cfg"

func save_selection(character_name: String, skin_name: String) -> void:
	var config := ConfigFile.new()
	config.set_value("character", "name", character_name)
	config.set_value("character", "skin", skin_name)
	config.save(SAVE_PATH)

func load_selection() -> Dictionary:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return {}

	return {
		"character": config.get_value("character", "name", ""),
		"skin": config.get_value("character", "skin", "default"),
	}
