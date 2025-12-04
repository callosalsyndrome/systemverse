extends Node

enum State {MENU, LOADING, BATTLE, PAUSE, DIALOGUE, GAMEPLAY, CUTSCENE, GAME_OVER, SETTINGS, SAVINGS}
var current_state: State = State.MENU
var previous_state: State = State.MENU

signal game_started()
signal savings_slots()
signal game_paused()
signal game_resumed()
signal returning_to_main_menu()

#signal state_changed(new_state)
#пока не нужны
#signal dialogue_started()
#signal dialogue_ended()
#signal cutscene_started()
#signal cutscene_ended()
#signal battle_started()
#signal battle_ended()
#signal battle_paused()
#signal battle_resumed()
#signal game_over()
#signal revived()

var position
var rotation
var count_scene

var config
var path_to_save_file := "user://gamesave.cfg"
var section_game := "slot1"

#func _ready():
#	load_game()
#	_connect_to_menu() 

#func save_game():
	#config.set_value(section_game, "position_player", player.position)
	#config.set_value(section_game, "rotation_player", player.rotation)
	#config.set_value(section_game, "count_scene", 1)
	#config.save(path_to_save_file)
	

# Загрузка данных
func load_game():
	config = ConfigFile.new()
	config.load(path_to_save_file)
	position = config.get_value(section_game, "position_player", Vector2.ZERO)
	rotation = config.get_value(section_game, "rotation_player", 0.0)
	count_scene = config.get_value(section_game, "count_scene", 0)
		
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
		if savings_scene.first_slot_selected.is_connected(_on_savings_scene_slot_pressed):
			savings_scene.first_slot_selected.disconnect(_on_savings_scene_slot_pressed)
			print("GSM: Старое подключение отключено")
		savings_scene.first_slot_selected.connect(_on_savings_scene_slot_pressed)
		savings_scene.second_slot_selected.connect(_on_savings_scene_slot_pressed)
		savings_scene.third_slot_selected.connect(_on_savings_scene_slot_pressed)
	else:
		print("GSM: нет сцены savings_scene или нет сигнала")

func _on_savings_scene_slot_pressed():
	print("GSM: Получен сигнал, что Выбран слот из savings_scene")
	game_started.connect(_connect_to_gameplay)
	game_started.emit()
	game_started.emit(State.GAMEPLAY)

func _creating_gameplay_scene():
	var gameplay_scene = preload("res://scenes/change_scene.tscn") 
	get_tree().change_scene_to_packed(gameplay_scene) 
	
func _connect_to_gameplay():
	print("GSM: Пытаемся найти gameplay...")
	_creating_gameplay_scene()
	await get_tree().tree_changed 
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
	returning_to_main_menu.connect(_connect_to_menu)
	_creating_menu_scene()
	returning_to_main_menu.emit()
	#returning_to_main_menu.emit(State.MENU)
		
#func change_state(new_state: State):
	#if new_state == current_state:
		#return
	#if not is_valid_transition(current_state, new_state):
		#push_warning("Invalid state transition: %s -> %s" % [State.keys()[current_state], State.keys()[new_state]])
		#return
	#previous_state = current_state
	#current_state = new_state
	#apply_state_effects(new_state, previous_state)
	#state_changed.emit(new_state, previous_state)
	#
#func is_valid_transition(from: State, to: State) -> bool:
	#var valid_transitions = {
		#State.MENU: [State.LOADING, State.GAMEPLAY, State.SETTINGS],
		#State.GAMEPLAY: [State.PAUSE, State.DIALOGUE, State.CUTSCENE, State.GAME_OVER, State.BATTLE],
		#State.PAUSE: [State.LOADING, State.GAMEPLAY],
		#State.LOADING: [State.MENU, State.GAMEPLAY],
		#State.GAME_OVER: [State.LOADING],
		#State.BATTLE: [State.GAMEPLAY,State.GAME_OVER],
		#State.CUTSCENE: [State.GAMEPLAY, State.PAUSE],
		#State.SETTINGS: [State.MENU, State.PAUSE],
		#State.DIALOGUE: [State.GAMEPLAY, State.PAUSE]
	#}
	#return to in valid_transitions.get(from, [])
	#
#func apply_state_effects(new_state: State, previous_state: State):
	#match new_state:
		#State.PAUSE: 
			#load("res://scenes/pause_scene.tscn")
			#Engine.time_scale = 0.0
			#if previous_state == State.GAMEPLAY:
				#game_paused.emit()
			#if previous_state == State.BATTLE:
				#battle_paused.emit()
		#
		#State.GAMEPLAY:
			#Engine.time_scale = 1.0
			#get_tree().change_scene_to_file("res://scenes/gameplay_scene.tscn")
			#if previous_state == State.PAUSE:
				#game_resumed.emit()
			#if previous_state == State.MENU:
				#game_started.emit()
			#if previous_state == State.DIALOGUE:
				#dialogue_ended.emit()
			#if previous_state == State.CUTSCENE:
				#cutscene_ended.emit()
			#if previous_state == State.GAME_OVER:
				#revived.emit()
			#if previous_state == State.BATTLE:
				#battle_ended.emit()
				#
		#State.BATTLE:
			#get_tree().change_scene_to_file("res://scenes/battle_scene.tscn")
			#Engine.time_scale = 1.0
			#if previous_state == State.PAUSE:
				#battle_resumed.emit()
			#if previous_state == State.GAMEPLAY:
				#battle_started.emit()
			#if previous_state == State.GAME_OVER:
				#revived.emit()
		#
		#State.DIALOGUE:
			#load("res://scenes/dialogue_scene.tscn")
			#Engine.time_scale = 0.0
			#dialogue_started.emit()
			#
		#State.CUTSCENE:
			#load("res://scenes/cutscene_scene.tscn")
			#Engine.time_scale = 0.0
			#cutscene_started.emit()
			#
		#State.MENU: 
			#get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
			#Engine.time_scale = 1.0
			#returning_to_main_menu.emit()
			#
		#State.GAME_OVER:
			#get_tree().change_scene_to_file("res://scenes/game_over_scene.tscn")
			#Engine.time_scale = 1.0
			#game_over.emit()
