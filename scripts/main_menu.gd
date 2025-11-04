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

func _on_start_button_pressed() -> void:
	start_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
	get_tree().quit() 
	#get_tree() - получает корневой объект сцены (SceneTree)
	#.quit() - метод для корректного завершения работы приложения
	
func _exit_tree():
	StartButton.pressed.disconnect(_on_start_button_pressed)
	ExitButton.pressed.disconnect(_on_exit_button_pressed)
