extends Node2D

 #по идее нажатие кнопки паузы должно сначала переносить на сцену слотов для сохранений, 
 #а потом после удачного выбора слота переносить на сцену геймплея
 #но поскольку у нас сейчас не реализованы сохранения в целом, лучше сначала разобраться с геймплеем
 #и потом если будет время мы сделаем сохранения
 #это должно быть проще если мы будем соблюдать архитектурные требования
 #просто к сигналам перехода между локациями например подключим функции сохранения прогресса
 #из SaveLoadManager-а.

@onready var StartButton = $CanvasGroup/Control/start_button #ссылки на кнопки можно переносить 
# из файловой системы напрямую. зажимаешь и перетаскиваешь в код
@onready var ExitButton = $CanvasGroup/Control/exit_button

signal start_button_pressed()
signal exit_button_pressed()

func _ready():
	add_to_group("menu_scene")
	StartButton.pressed.connect(_on_start_button_pressed)
	ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed() -> void:
	print("Начать")
	var connections = get_signal_connection_list("start_button_pressed")
	print("Всего подключений к сигналу 'pressed': ", connections.size())
	for connection in connections:
		print("Подключение: ", connection)
	start_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		SaveLoadManager.position = player.position
		print("Позиция игрока сохранена: ", player.position)
	else:
		print("Player не найден")	
	SaveLoadManager.save_game()
	get_tree().quit() 
	
#func _exit_tree():
	#StartButton.pressed.disconnect(_on_start_button_pressed)
	#ExitButton.pressed.disconnect(_on_exit_button_pressed)
