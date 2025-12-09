extends Node2D

@onready var StartButton = $CanvasGroup/Control/start_button 
@onready var ExitButton = $CanvasGroup/Control/exit_button

signal start_button_pressed()
signal exit_button_pressed()

func _ready():
	add_to_group("menu_scene")
	StartButton.pressed.connect(_on_start_button_pressed)
	ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	#var connections = get_signal_connection_list("start_button_pressed")
	#print("Всего подключений к сигналу 'pressed': ", connections.size())
	#for connection in connections:
		#print("Подключение: ", connection)
	start_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveLoadManager.position = player.position
		print("Позиция игрока Шсохранена: ", player.position)
	else:
		print("Player не найденьь")	
	SaveLoadManager.save_game()
	get_tree().quit() 
