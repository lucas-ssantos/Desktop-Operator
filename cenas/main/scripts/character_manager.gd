extends Node

const CHIBIS_PATH := "res://chibis/"
const ANIMATIONS := ["idle", "walking", "sitting", "sleeping", "click"]
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

func load_character_frames(character_name: String) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if frames.has_animation("default"):
		frames.remove_animation("default")

	var character_path := CHIBIS_PATH.path_join(character_name).path_join("frames")

	for anim_name in ANIMATIONS:
		var anim_path := character_path.path_join(anim_name)
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
