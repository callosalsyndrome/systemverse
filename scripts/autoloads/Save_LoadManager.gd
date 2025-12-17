extends Node

# Загружаем сцену подтверждения
var delete_confirm_scene = preload("res://scenes/deleting_confirm.tscn")


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

# Переменная для хранения callback-функции, которая будет вызвана после подтверждения
var pending_delete_callback = null

func _ready() -> void:
	print("SaveLoadManager загружен")
	
	# Создаем таймер для автоматического удаления анимации
	animation_timer = Timer.new()
	animation_timer.one_shot = true
	animation_timer.timeout.connect(_on_animation_timer_timeout)
	add_child(animation_timer)

# Новая функция для запроса подтверждения удаления
func request_delete_confirmation(slot_name: String, delete_callback: Callable) -> void:
	section_name = slot_name
	pending_delete_callback = delete_callback
	
	print("Запрос подтверждения удаления для слота: ", slot_name)
	
	# Блокируем кнопки слотов сохранения
	_block_save_slots(true)
	
	# Создаем новый экземпляр каждый раз
	var delete_confirm_instance = delete_confirm_scene.instantiate()
	if delete_confirm_instance == null:
		push_error("Не удалось создать экземпляр deleting_confirm!")
		_block_save_slots(false)
		return
	
	# Подключаем сигналы с использованием Callable для корректного отслеживания
	delete_confirm_instance.confirmed.connect(_on_delete_confirmed.bind(delete_confirm_instance))
	delete_confirm_instance.cancelled.connect(_on_delete_cancelled.bind(delete_confirm_instance))
	
	get_tree().root.add_child(delete_confirm_instance)
	print("DeletingConfirm добавлен в дерево сцены")
	
	delete_confirm_instance.show_confirm()
	print("Показываем окно подтверждения удаления")

func _on_delete_confirmed(confirm_instance) -> void:
	# Пользователь подтвердил удаление
	print("Удаление подтверждено")
	
	# Разблокируем кнопки
	_block_save_slots(false)
	
	# Удаляем экземпляр окна
	if confirm_instance and is_instance_valid(confirm_instance):
		confirm_instance.queue_free()
	
	if pending_delete_callback:
		pending_delete_callback.call()
		pending_delete_callback = null

func _on_delete_cancelled(confirm_instance) -> void:
	# Пользователь отказался от удаления
	print("Удаление отменено")
	
	# Разблокируем кнопки
	_block_save_slots(false)
	
	# Удаляем экземпляр окна
	if confirm_instance and is_instance_valid(confirm_instance):
		confirm_instance.queue_free()
	
	pending_delete_callback = null

func _block_save_slots(block: bool):
	# Ищем ВСЕ сцены SavingsScene (могут быть несколько, если не удаляются)
	var savings_scenes = []
	
	# Ищем в корне
	for child in get_tree().root.get_children():
		if child.name == "SavingsScene" or child.is_in_group("savings_scene"):
			savings_scenes.append(child)
	
	# Также ищем среди всех узлов рекурсивно
	_find_savings_scenes_recursive(get_tree().root, savings_scenes)
	
	for savings_scene in savings_scenes:
		if is_instance_valid(savings_scene):
			var slots = ["SaveSlot", "SaveSlot2", "SaveSlot3"]
			for slot_name in slots:
				var slot = savings_scene.get_node_or_null(slot_name)
				if slot and slot is BaseButton:
					slot.disabled = block
					print("Кнопка ", slot_name, " в сцене ", savings_scene.name, " заблокирована: ", block)

# Рекурсивный поиск сцен сохранения
func _find_savings_scenes_recursive(node: Node, result: Array):
	for child in node.get_children():
		if child.name == "SavingsScene" or child.is_in_group("savings_scene"):
			if not result.has(child):
				result.append(child)
		_find_savings_scenes_recursive(child, result)

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
		
		# Можно добавить обновление UI или другие действия после удаления
		# Например, обновить отображение слотов сохранения
	else:
		print("Секция '", section_to_remove, "' не существует")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("закрытие")
		save_game()
