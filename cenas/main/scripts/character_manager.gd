extends Node

const CHIBIS_PATH := "res://chibis/"
const ANIMATIONS := ["idle", "walking", "sitting", "sleeping", "click", "special"]
const LOOPING_ANIMATIONS := ["idle", "walking", "sitting", "sleeping"]

const ANIMATION_FPS := {
	"idle": 8,
	"walking": 8,
	"sitting": 8,
	"sleeping": 6,
	"click": 10,
}

# --- Helpers de listagem ---
# Usa ResourceLoader.list_directory() em vez de DirAccess: o DirAccess não
# lista corretamente pastas dentro de um build exportado (.pck), só no editor.

func _list_subfolders(path: String) -> Array[String]:
	var names: Array[String] = []
	for entry in ResourceLoader.list_directory(path):
		if entry.ends_with("/"):
			var folder_name := entry.trim_suffix("/")
			if not folder_name.begins_with("."):
				names.append(folder_name)
	return names

func _list_files_with_extensions(path: String, extensions: Array[String]) -> Array[String]:
	var files: Array[String] = []
	for entry in ResourceLoader.list_directory(path):
		if not entry.ends_with("/"):
			var ext := entry.get_extension().to_lower()
			if ext in extensions:
				files.append(entry)
	files.sort()
	return files

# --- Personagens e skins ---

func get_character_list() -> Array[String]:
	var characters := _list_subfolders(CHIBIS_PATH)
	characters.sort()
	return characters

func get_skin_list(character_name: String) -> Array[String]:
	var character_path := CHIBIS_PATH.path_join(character_name)
	var skins := _list_subfolders(character_path)
	skins.sort()

	if skins.has("default"):
		skins.erase("default")
		skins.push_front("default")

	return skins

# --- Frames ---

func load_character_frames(character_name: String, skin_name: String = "default") -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	var frames_path := CHIBIS_PATH.path_join(character_name).path_join(skin_name).path_join("frames")

	for anim_name in ANIMATIONS:
		var anim_path := frames_path.path_join(anim_name)
		var textures := _load_textures_sorted(anim_path)

		if textures.is_empty():
			push_warning("Nenhum frame encontrado para '%s' em %s" % [anim_name, anim_path])
			continue

		frames.add_animation(anim_name)
		frames.set_animation_speed(anim_name, ANIMATION_FPS.get(anim_name, 8))
		frames.set_animation_loop(anim_name, anim_name in LOOPING_ANIMATIONS)

		for texture in textures:
			frames.add_frame(anim_name, texture)

	return frames

func _load_textures_sorted(folder_path: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var file_names := _list_files_with_extensions(folder_path, ["png", "webp"])

	for name in file_names:
		var texture: Texture2D = load(folder_path.path_join(name))
		if texture:
			textures.append(texture)

	return textures

# --- Categorização de áudio ---

var _trailing_digits_regex: RegEx

func _get_trailing_digits_regex() -> RegEx:
	if _trailing_digits_regex == null:
		_trailing_digits_regex = RegEx.new()
		_trailing_digits_regex.compile("\\d+$")
	return _trailing_digits_regex

func _categorize_audio_file(base_name: String) -> String:
	var regex := _get_trailing_digits_regex()
	var result := regex.search(base_name)
	if result:
		var prefix := base_name.substr(0, base_name.length() - result.get_string().length())
		return prefix + "_variations"
	return base_name

# --- Idiomas ---

func get_available_languages(character_name: String, skin_name: String) -> Array[String]:
	var languages := _scan_language_folders(character_name, skin_name)
	if languages.is_empty() and skin_name != "default":
		languages = _scan_language_folders(character_name, "default")
	return languages

func _scan_language_folders(character_name: String, skin_name: String) -> Array[String]:
	var audio_path := CHIBIS_PATH.path_join(character_name).path_join(skin_name).path_join("audio")
	var languages := _list_subfolders(audio_path)
	languages.sort()
	return languages

# --- Áudio ---

func load_character_audio(character_name: String, skin_name: String = "default", language: String = "EN", trust: int = 0) -> Dictionary:
	var audio_by_category := _load_audio_from_folder(character_name, skin_name, language)

	if audio_by_category.is_empty() and skin_name != "default":
		audio_by_category = _load_audio_from_folder(character_name, "default", language)

	return _apply_trust_unlocks(audio_by_category, trust)

func _apply_trust_unlocks(audio_by_category: Dictionary, trust: int) -> Dictionary:
	var result := audio_by_category.duplicate(true)

	var unlocked_trust_talks := 0
	if trust >= 150:
		unlocked_trust_talks = 3
	elif trust >= 100:
		unlocked_trust_talks = 2
	elif trust >= 50:
		unlocked_trust_talks = 1

	if unlocked_trust_talks > 0 and result.has("talk_trust_variations"):
		var trust_pool: Array = result["talk_trust_variations"]
		var unlocked_pool: Array = trust_pool.slice(0, mini(unlocked_trust_talks, trust_pool.size()))

		if not result.has("talk_variations"):
			result["talk_variations"] = []
		result["talk_variations"] += unlocked_pool

	result.erase("talk_trust_variations")

	if trust >= 100 and result.has("trust_tap") and not result["trust_tap"].is_empty():
		result["tap"] = result["trust_tap"]
	result.erase("trust_tap")

	return result

func _load_audio_from_folder(character_name: String, skin_name: String, language: String) -> Dictionary:
	var audio_by_category: Dictionary = {}
	var audio_path := CHIBIS_PATH.path_join(character_name).path_join(skin_name).path_join("audio").path_join(language)

	var file_names := _list_files_with_extensions(audio_path, ["ogg", "wav"])

	for name in file_names:
		var base_name := name.get_basename()
		var category := _categorize_audio_file(base_name)
		var stream: AudioStream = load(audio_path.path_join(name))
		if stream:
			if not audio_by_category.has(category):
				audio_by_category[category] = []
			audio_by_category[category].append(stream)

	return audio_by_category
