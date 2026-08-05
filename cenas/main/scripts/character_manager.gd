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

func get_character_list() -> Array[String]:
	var characters: Array[String] = []
	var dir := DirAccess.open(CHIBIS_PATH)

	if dir == null:
		push_error("Não foi possível abrir a pasta: %s" % CHIBIS_PATH)
		return characters

	dir.list_dir_begin()
	var folder_name := dir.get_next()
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			characters.append(folder_name)
		folder_name = dir.get_next()
	dir.list_dir_end()

	characters.sort()
	return characters

func get_skin_list(character_name: String) -> Array[String]:
	var skins: Array[String] = []
	var character_path := CHIBIS_PATH.path_join(character_name)
	var dir := DirAccess.open(character_path)
	if dir == null:
		return skins

	dir.list_dir_begin()
	var folder_name := dir.get_next()
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			skins.append(folder_name)
		folder_name = dir.get_next()
	dir.list_dir_end()

	skins.sort()
	if skins.has("default"):
		skins.erase("default")
		skins.push_front("default")

	return skins

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

var _trailing_digits_regex: RegEx

func _get_trailing_digits_regex() -> RegEx:
	if _trailing_digits_regex == null:
		_trailing_digits_regex = RegEx.new()
		_trailing_digits_regex.compile("\\d+$")
	return _trailing_digits_regex

func _categorize_audio_file(base_name: String) -> String:
	# Sem número no final -> categoria própria (ex: "greetings", "talk", "idle")
	# Com número no final -> pool de variação agrupado (ex: "talk1"/"talk2"/"talk3" -> "talk_variations")
	var regex := _get_trailing_digits_regex()
	var result := regex.search(base_name)
	if result:
		var prefix := base_name.substr(0, base_name.length() - result.get_string().length())
		return prefix + "_variations"
	return base_name

func get_available_languages(character_name: String, skin_name: String) -> Array[String]:
	var languages := _scan_language_folders(character_name, skin_name)
	if languages.is_empty() and skin_name != "default":
		languages = _scan_language_folders(character_name, "default")
	return languages

func _scan_language_folders(character_name: String, skin_name: String) -> Array[String]:
	var languages: Array[String] = []
	var audio_path := CHIBIS_PATH.path_join(character_name).path_join(skin_name).path_join("audio")
	var dir := DirAccess.open(audio_path)
	if dir == null:
		return languages

	dir.list_dir_begin()
	var folder_name := dir.get_next()
	while folder_name != "":
		if dir.current_is_dir() and not folder_name.begins_with("."):
			languages.append(folder_name)
		folder_name = dir.get_next()
	dir.list_dir_end()

	languages.sort()
	return languages

func load_character_audio(character_name: String, skin_name: String = "default", language: String = "EN") -> Dictionary:
	# Retorna algo como:
	# { "greetings": [stream], "tap": [stream], "idle": [stream], "talk_variations": [stream1, stream2, stream3] }
	var audio_by_category := _load_audio_from_folder(character_name, skin_name, language)

	# Fallback: se essa skin não tiver nenhum áudio próprio (nesse idioma), usa o da skin "default"
	if audio_by_category.is_empty() and skin_name != "default":
		audio_by_category = _load_audio_from_folder(character_name, "default", language)

	return audio_by_category

func _load_audio_from_folder(character_name: String, skin_name: String, language: String) -> Dictionary:
	var audio_by_category: Dictionary = {}
	var audio_path := CHIBIS_PATH.path_join(character_name).path_join(skin_name).path_join("audio").path_join(language)

	var dir := DirAccess.open(audio_path)
	if dir == null:
		return audio_by_category

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".ogg") or file_name.ends_with(".wav")):
			var base_name := file_name.get_basename()
			var category := _categorize_audio_file(base_name)
			var stream: AudioStream = load(audio_path.path_join(file_name))
			if stream:
				if not audio_by_category.has(category):
					audio_by_category[category] = []
				audio_by_category[category].append(stream)
		file_name = dir.get_next()
	dir.list_dir_end()

	return audio_by_category

func _load_textures_sorted(folder_path: String) -> Array[Texture2D]:
	var textures: Array[Texture2D] = []
	var dir := DirAccess.open(folder_path)
	if dir == null:
		return textures

	var file_names: Array[String] = []
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".png") or file_name.ends_with(".webp")):
			file_names.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	file_names.sort()

	for name in file_names:
		var texture: Texture2D = load(folder_path.path_join(name))
		if texture:
			textures.append(texture)

	return textures
