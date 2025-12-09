extends Node

var position
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
	var config2 = ConfigFile.new()
	# Проверяем, существует ли файл
	if not FileAccess.file_exists(path_to_save_file):
		print("Файл конфигурации не существует")
		return
	# Загружаем файл
	var error = config2.load(path_to_save_file)
	if error != OK:
		print("Ошибка загрузки файла:", error_string(error))
		return
	var section_to_remove = section_name
	# Проверяем, существует ли секция
	if config2.has_section(section_to_remove):
		# Удаляем секцию
		config2.erase_section(section_to_remove)
		# Сохраняем изменения
		config2.save(path_to_save_file)
		print("Секция '", section_to_remove, "' удалена")
	else:
		print("Секция '", section_to_remove, "' не существует")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("закрытие")
		save_game()
