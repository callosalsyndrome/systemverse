extends Node

var position
var rotation # поворот
var count_scene
var current_scene_name
var section_name

var default_position = null

var config 
var path_to_save_file := "user://SavedGameData.cfg" # "%APPDATA%\Godot\app_userdata\"

func _ready() -> void:
	print("SaveLoadManager загружен")

func save_game() -> void:
	# секция ключ значения
	config.set_value(section_name, "position", position)
	config.set_value(section_name, "current_scene_name", current_scene_name)
	config.save(path_to_save_file)
	print("Игра сохранена!")

func load_game() -> void: 
	config = ConfigFile.new() 
	config.load(path_to_save_file) 
	
	position = config.get_value(section_name, "position", default_position)
	current_scene_name = config.get_value(section_name, "current_scene_name", "gameplay_scene")
	print("Игра загружена!")

func delete_section() -> void: 
	#var config2 = ConfigFile.new()
	#config2.load(path_to_save_file)
	#config2.erase_section(section_name)
	#config2.save(path_to_save_file)
	print("3. Попытка удаления завершена")
	
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()
