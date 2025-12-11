# BackgroundMusic.gd
extends AudioStreamPlayer

var current_music: AudioStream = null
var fade_duration: float = 1.0
var default_music: AudioStream = preload("res://assets/sounds/【BOFU2017】 - homesick  RIN【BGA】.mp3")
var is_changing_scene: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	print("BackgroundMusic: Загружен")
	
	# Воспроизводим музыку по умолчанию на старте
	if default_music:
		current_music = default_music
		stream = default_music
		play()
		print("BackgroundMusic: Воспроизвожу музыку по умолчанию")
	
	# Подписываемся на изменение дерева сцен
	get_tree().tree_changed.connect(_on_tree_changed)
	
	# Проверяем начальную сцену с задержкой
	await get_tree().create_timer(0.5).timeout
	_check_current_scene()

func _on_tree_changed():
	# Ждем завершения смены сцены
	if is_changing_scene:
		return
	
	is_changing_scene = true
	await get_tree().create_timer(0.3).timeout
	is_changing_scene = false
	
	_check_current_scene()

func _check_current_scene():
	"""Проверить текущую сцену на наличие музыки"""
	var current_scene = get_tree().current_scene
	if not current_scene or not is_instance_valid(current_scene):
		print("BackgroundMusic: Текущая сцена недействительна")
		return
	
	print("BackgroundMusic: Проверяю сцену: ", current_scene.name)
	
	# Для сцены change_scene ищем музыку в дочерних сценах
	if current_scene.name == "change_scene" or current_scene.name.begins_with("change"):
		_find_music_in_child_scenes(current_scene)
	else:
		# Для обычных сцен проверяем напрямую
		_check_scene_for_music(current_scene)

func _find_music_in_child_scenes(parent: Node):
	"""Искать музыку в дочерних сценах change_scene"""
	# Даем время дочерним сценам загрузиться
	await get_tree().process_frame
	await get_tree().process_frame
	
	for child in parent.get_children():
		if is_instance_valid(child):
			print("BackgroundMusic: Проверяю дочернюю сцену: ", child.name)
			
			# Ищем музыку в дочерней сцене
			var music = _get_music_from_node(child)
			if music:
				print("BackgroundMusic: Нашел музыку в дочерней сцене: ", child.name)
				if music != current_music:
					_set_music(music)
				return
	
	print("BackgroundMusic: Музыка не найдена в дочерних сценах")

func _check_scene_for_music(scene: Node):
	"""Проверить обычную сцену на наличие музыки"""
	var music = _get_music_from_node(scene)
	if music:
		print("BackgroundMusic: Нашел музыку в сцене: ", scene.name)
		if music != current_music:
			_set_music(music)
	else:
		print("BackgroundMusic: У сцены ", scene.name, " нет своей музыки")

func _get_music_from_node(node: Node) -> AudioStream:
	"""Безопасно получить музыку из узла (исправленная версия для Godot 4)"""
	if not is_instance_valid(node):
		return null
	
	# Способ 1: Через метод get_background_music
	if node.has_method("get_background_music"):
		var music = node.call("get_background_music")
		if music and music is AudioStream:
			return music
	
	# Способ 2: Через поиск свойства в списке свойств
	# В Godot 4 нужно использовать get_property_list() вместо has_property()
	var music = _find_property_in_list(node, "background_music")
	if music and music is AudioStream:
		return music
	
	return null

func _find_property_in_list(node: Node, property_name: String) -> Variant:
	"""Найти свойство в списке свойств узла"""
	for property_dict in node.get_property_list():
		if property_dict["name"] == property_name:
			# Нашли свойство, получаем его значение
			return node.get(property_name)
	return null

func _set_music(new_music: AudioStream):
	"""Установить новую музыку с плавным переходом"""
	if not new_music or new_music == current_music:
		return
	
	print("BackgroundMusic: Устанавливаю новую музыку")
	current_music = new_music
	
	# Если уже играет музыка, делаем плавный переход
	if playing and stream != new_music:
		print("BackgroundMusic: Плавный переход с текущей музыки")
		await _fade_out(fade_duration)
	
	stream = new_music
	
	# Плавное появление
	if fade_duration > 0:
		print("BackgroundMusic: Плавное появление новой музыки")
		volume_db = -80.0
		play()
		await _fade_in(fade_duration)
	else:
		print("BackgroundMusic: Мгновенный старт новой музыки")
		volume_db = 0.0
		play()

func _fade_in(duration: float):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", 0.0, duration)
	await tween.finished
	print("BackgroundMusic: Музыка полностью заиграла")

func _fade_out(duration: float):
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -80.0, duration)
	await tween.finished
	if stream == current_music:
		stop()
	print("BackgroundMusic: Текущая музыка затухла")

# Альтернативная упрощенная версия
func _get_music_simple(node: Node) -> AudioStream:
	"""Упрощенный способ получить музыку из узла"""
	if not is_instance_valid(node):
		return null
	
	# Пробуем получить свойство напрямую
	# Если свойства нет, get() вернет null - это безопасно
	var music = node.get("background_music")
	
	# Проверяем, что это AudioStream
	if music and music is AudioStream:
		return music
	
	return null

# Используйте эту функцию вместо _get_music_from_node для простоты:
func _check_scene_for_music_simple(scene: Node):
	"""Упрощенная проверка сцены"""
	var music = scene.get("background_music")
	if music and music is AudioStream:
		print("BackgroundMusic: Нашел музыку в сцене: ", scene.name)
		if music != current_music:
			_set_music(music)
	else:
		print("BackgroundMusic: У сцены ", scene.name, " нет своей музыки")
