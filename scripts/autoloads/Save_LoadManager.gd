extends Node

# Загружаем сцену как PackedScene
var save_animation_scene = preload("res://scenes/save_animation.tscn")
# Ссылка на текущий экземпляр анимации
var current_animation_instance = null
# Таймер для автоматического удаления анимации
var animation_timer = null

var position
var count_scene
var current_scene_name
var section_name
var flag

var default_position = null

var config 
var path_to_save_file := "user://SavedGameData.cfg"

func _ready() -> void:
	print("SaveLoadManager загружен")
	# Создаем таймер для автоматического удаления анимации
	animation_timer = Timer.new()
	animation_timer.one_shot = true
	animation_timer.timeout.connect(_on_animation_timer_timeout)
	add_child(animation_timer)

func save_game() -> void:
	# Проверяем, что config инициализирован
	if config == null:
		config = ConfigFile.new()
	
	# Проверяем, что section_name установлен
	if section_name == null or section_name == "":
		print("Ошибка: section_name не установлен!")
		return
	
	# Сохраняем данные
	config.set_value(section_name, "position", position)
	config.set_value(section_name, "current_scene_name", current_scene_name)
	config.save(path_to_save_file)
	print("Игра сохранена!")
	
	# Показываем анимацию сохранения
	show_save_animation()

func show_save_animation() -> void:
	# Удаляем предыдущую анимацию, если она есть
	if current_animation_instance != null:
		current_animation_instance.queue_free()
	
	# Создаем новый экземпляр сцены анимации
	current_animation_instance = save_animation_scene.instantiate()
	
	# Добавляем сцену анимации в дерево сцены
	get_tree().root.add_child(current_animation_instance)
	
	# Находим AnimatedSprite2D в созданной сцене
	var animated_sprite = current_animation_instance.get_node("AnimatedSprite2D")
	
	if animated_sprite != null:
		# Показываем и запускаем анимацию
		animated_sprite.show()
		animated_sprite.play()
	else:
		print("Ошибка: AnimatedSprite2D не найден в сцене сохранения!")
	
	# Запускаем таймер на 5 секунд для удаления анимации
	animation_timer.start(5.0)

func _on_animation_timer_timeout() -> void:
	# Удаляем анимацию через 5 секунд
	if current_animation_instance != null:
		current_animation_instance.queue_free()
		current_animation_instance = null
		print("Анимация сохранения скрыта")

func load_game() -> void: 
	config = ConfigFile.new() 
	var error = config.load(path_to_save_file)
	
	if error != OK:
		print("Ошибка загрузки файла сохранения: ", error_string(error))
		return
	
	position = config.get_value(section_name, "position", default_position)
	current_scene_name = config.get_value(section_name, "current_scene_name", "gameplay_scene")
	flag = false
	print("Игра загружена!")

func delete_section() -> void: 
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
