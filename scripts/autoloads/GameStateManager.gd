extends Node

enum State {MENU, LOADING, BATTLE, PAUSE, DIALOGUE, GAMEPLAY, CUTSCENE, GAME_OVER, SETTINGS, SAVINGS}
var current_state: State = State.MENU
var previous_state: State = State.MENU

signal game_started()
signal savings_slots()
signal game_paused()
signal game_resumed()
signal returning_to_main_menu()

func _ready():
	_connect_to_menu() 

func save_game() -> void:
	SaveLoadManager.save_game()
	
func load_game(): 
	SaveLoadManager.load_game()


func _creating_menu_scene():
	print("Создано меню")
	var menu_scene = preload("res://scenes/menu_scene.tscn") 
	get_tree().change_scene_to_packed(menu_scene) 
	
func _connect_to_menu():
	print("GSM: Пытаемся найти меню...")
	#_creating_menu_scene()
	await get_tree().tree_changed 
	await get_tree().process_frame
	await get_tree().process_frame
	
	var menu = get_tree().current_scene
	if menu:
		# Отключаем старые подключения перед новыми (для безопасности)
		if menu.start_button_pressed.is_connected(_on_menu_start_pressed):
			menu.start_button_pressed.disconnect(_on_menu_start_pressed)
			print("GSM: Старое подключение отключено")
		menu.start_button_pressed.connect(_on_menu_start_pressed)
		print("Подключен сигнал")
	else: 
		print("Нет сцена меню")

func _on_menu_start_pressed():
	print("GSM: Получен сигнал старта из меню")
	savings_slots.connect(_connect_to_savings_scene)
	savings_slots.emit() 
	savings_slots.emit(State.SAVINGS)

func _creating_savings_scene():
	var savings_scene = preload("res://scenes/savings_scene.tscn") 
	get_tree().change_scene_to_packed(savings_scene) 

func _connect_to_savings_scene():
	print("GSM: Пытаемся найти выбор слотов...")
	_creating_savings_scene()
	await get_tree().tree_changed 
	var savings_scene = get_tree().current_scene
	if (savings_scene 
			and savings_scene.has_signal("first_slot_selected") 
			and savings_scene.has_signal("second_slot_selected") 
			and savings_scene.has_signal("third_slot_selected")):
		savings_scene.first_slot_selected.connect(_on_savings_scene_first_slot_pressed)
		savings_scene.second_slot_selected.connect(_on_savings_scene_second_slot_pressed)
		savings_scene.third_slot_selected.connect(_on_savings_scene_third_slot_pressed)
	else:
		print("GSM: нет сцены savings_scene или нет сигнала")

func _on_savings_scene_first_slot_pressed():
	print("GSM: Получен сигнал, что Выбран первый слот из savings_scene")
	SaveLoadManager.section_name = "first_slot"
	load_game()
	game_started.connect(_connect_to_gameplay)
	game_started.emit()

func _on_savings_scene_second_slot_pressed():
	print("GSM: Получен сигнал, что Выбран второй слот из savings_scene")
	SaveLoadManager.section_name = "second_slot"
	load_game()
	game_started.connect(_connect_to_gameplay)
	game_started.emit()

func _on_savings_scene_third_slot_pressed():
	print("GSM: Получен сигнал, что Выбран третий слот из savings_scene")
	SaveLoadManager.section_name = "third_slot"
	load_game()
	game_started.connect(_connect_to_gameplay)
	game_started.emit()

func _creating_change_scene():
	print("GSM: Создаем gameplay...")
	var change_scene = preload("res://scenes/change_scene.tscn") 
	get_tree().change_scene_to_packed(change_scene) 
	#var gameplay_scene = preload("res://scenes/change_scene.tscn").instantiate()
	#for child in gameplay_scene.get_children():
		#if child is Node2D:  # или другая проверка
			#child.queue_free()
	#var current_scene = load("res://scenes/" + SaveLoadManager.current_scene_name + ".tscn").instantiate()
	#gameplay_scene.add_child(current_scene)
	#get_tree().change_scene_to_packed(gameplay_scene) 
	#print("GSM: Загружаем gameplay...")
	
func _connect_to_gameplay():
	print("GSM: Пытаемся найти gameplay...")
	_creating_change_scene()
	#await get_tree().tree_changed 
	await get_tree().process_frame
	# Ищем Player по группе
	#print("ищем")
	#var player = get_tree().get_first_node_in_group("player")
	#if player:
		#SaveLoadManager.default_position = player.position
		#print("найден игрок")
	
	print("GSM: Меняем на gameplay...")
	var gameplay_scene = get_tree().current_scene
	if gameplay_scene and gameplay_scene.has_signal("game_started"):
		print("GSM: Сигнал подключен")
	else:
		print("GSM: нет сцены или нет сигнала")

func _input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().current_scene.name != "SavingsScene" and get_tree().current_scene.name != "Menu":
		if get_tree().paused:
			game_resumed.connect(_on_resume_button_pressed)
			game_resumed.emit() 
			game_resumed.emit(State.GAMEPLAY)
		else:
			game_paused.connect(_connect_to_pause_scene)
			game_paused.emit() 
			game_paused.emit(State.PAUSE)

func _creating_pause_scene():
	print("GSM: Создаем сцену паузы")
	var pause_scene = load("res://scenes/pause_scene.tscn").instantiate()
	return pause_scene

func _connect_to_pause_scene():
	print("GSM: Пытаемся найти сцену паузы...")
	get_tree().paused = true
	var pause_scene = _creating_pause_scene()
	#pause_scene.z_index = 15
	
	#var viewport_size = get_viewport().get_visible_rect().size
	#pause_scene.position = viewport_size / 2
		
		
	add_child(pause_scene) 
	if pause_scene:
		pause_scene.resume_button_pressed.connect(_on_resume_button_pressed.bind(pause_scene))
		pause_scene.exit_to_menu_button_pressed.connect(_on_exit_to_menu_button_pressed.bind(pause_scene))
		print("GSM: Сигнал подключен")
	else:
		print("GSM: нет сцены или нет сигнала")

func _on_resume_button_pressed(pause_scene):
	get_tree().paused = false
	print("GSM: Получен сигнал, что нажата кнопка resume_button_pressed")
	pause_scene.queue_free()
	game_started.emit(State.GAMEPLAY)

func _on_exit_to_menu_button_pressed(pause_scene):
	get_tree().paused = false
	pause_scene.queue_free()
	print("GSM: Получен сигнал, что нажата кнопка exit_to_menu_button_pressed")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveLoadManager.position = player.position
		print("Позиция игрока сохранена: ", player.position)
	else:
		print("Player не найден")	
	SaveLoadManager.save_game()
	returning_to_main_menu.connect(_connect_to_menu)
	_creating_menu_scene()
	returning_to_main_menu.emit()
