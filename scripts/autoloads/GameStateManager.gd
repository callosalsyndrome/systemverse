extends Node

enum State {MENU, LOADING, BATTLE, PAUSE, DIALOGUE, GAMEPLAY, CUTSCENE, GAME_OVER, SETTINGS, SAVINGS}
var current_state: State = State.MENU
var previous_state: State = State.MENU

signal game_started()
signal savings_slots

#signal state_changed(new_state)
#signal game_paused()
#signal game_resumed()
#signal returning_to_main_menu()
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

func _ready():
	_connect_to_menu() 

func _connect_to_menu():
	print("GSM: Пытаемся найти меню...")
	var menu = get_tree().current_scene
	if menu:
		# Отключаем старые подключения перед новыми (для безопасности)
		if menu.start_button_pressed.is_connected(_on_menu_start_pressed):
			menu.start_button_pressed.disconnect(_on_menu_start_pressed)
			print("GSM: Старое подключение отключено")
		menu.start_button_pressed.connect(_on_menu_start_pressed)

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
		print("GSM: Сигнал подключен")
	else:
		print("GSM: нет сцены или нет сигнала")

func _on_savings_scene_slot_pressed():
	print("GSM: Получен сигнал, что Выбран слот из savings_scene")
	game_started.connect(_connect_to_gameplay)
	game_started.emit()
	game_started.emit(State.GAMEPLAY)

func _creating_gameplay_scene():
	# Загружаем и создаем геймплейную сцену
	var gameplay_scene = preload("res://scenes/gameplay_scene.tscn") 
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
