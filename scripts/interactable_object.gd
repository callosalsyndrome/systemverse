extends Node2D

signal player_entered_interaction_zone(object_name)
signal player_exited_interaction_zone(object_name)

signal interaction_triggered(object)
signal interaction_started(object)

@onready var area_2d = $Area2D

func _ready():
	$AnimatedSprite2D.play("glow")
	$AnimatedSprite2D/ColorRect.hide()
	area_2d.connect("body_entered", _on_body_entered)
	area_2d.connect("body_exited", _on_body_exited)
	set_process_input(true)
	
func _input(event):
	if is_player_in_zone() and event.is_action_pressed("interact"):
		handle_interaction()
	
func handle_interaction():
	print("Взаимодействие с объектом:", name)
	interaction_started.emit(self)
	perform_interaction()
	
func perform_interaction(): #переопределяется для дочерних классов
	print("Взаимодействие с ", name)
	interaction_triggered.emit()

func _on_body_entered(body: Node):
	# Проверяем, что вошел игрок (по имени или группе)
	if body.is_in_group("player") or body.name == "Player":
		print("Игрок вошел в зону взаимодействия: ", name)
		
		# Отправляем сигнал в GameStateManager
		player_entered_interaction_zone.emit(name)
		
		# Также можно напрямую эмитить в GSM, если он подключен
		if GameStateManager:
			GameStateManager.emit_signal("player_entered_interaction_zone", name)
		$AnimatedSprite2D/ColorRect.show()
		

func _on_body_exited(body: Node):
	# Проверяем, что вышел игрок
	if body.is_in_group("player") or body.name == "Player":
		print("Игрок вышел из зоны взаимодействия: ", name)
		
	# Отправляем сигнал в GameStateManager
		player_exited_interaction_zone.emit(name)

		# Также можно напрямую эмитить в GSM
		if GameStateManager:
			GameStateManager.emit_signal("player_exited_interaction_zone", name)
		
		$AnimatedSprite2D/ColorRect.hide()

# Функция для принудительной проверки наличия игрока в зоне
func is_player_in_zone() -> bool:
	var bodies = area_2d.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player") or body.name == "Player":
			return true
	return false

func _exit_tree():
	# Отключаем сигналы при удалении объекта
	if area_2d and area_2d.is_connected("body_entered", _on_body_entered):
		area_2d.disconnect("body_entered", _on_body_entered)
	if area_2d and area_2d.is_connected("body_exited", _on_body_exited):
		area_2d.disconnect("body_exited", _on_body_exited)
