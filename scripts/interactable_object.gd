extends Node2D

signal player_entered_interaction_zone(object_name)
signal player_exited_interaction_zone(object_name)

signal interaction_triggered(object)
signal interaction_started(object)

@export var is_gameplay_trigger: bool = false
@export var is_final_trigger: bool = false
var camera_already_triggered = false
var panel_already_activated

@onready var area_2d = $Area2D

@export var dialog_id: String = ""

func _ready():
	$AnimatedSprite2D.play("glow")
	$AnimatedSprite2D/ColorRect.hide()
	area_2d.connect("body_entered", _on_body_entered)
	area_2d.connect("body_exited", _on_body_exited)
	set_process_input(true)
	
func _input(event):
	if is_player_in_zone() and event.is_action_pressed("interact"):
		
		if not DialogManager.is_dialog_active:
			print("кнопка interact нажата")
			handle_interaction()
		#handle_interaction()
	
func handle_interaction():
	#print("Взаимодействие ппппп с объектом:", name)
	interaction_started.emit(self)
	perform_interaction()
	
#!!!!!!!!!!!!!!!!!!!!!!!!
func perform_interaction(): #переопределяется для дочерних классов
	#print("Взаимодействие с ", name)
	interaction_triggered.emit()
	print("Взаимодействие с ", name)
	
	if name == "InteractableObjectLift":
		print("Активация лифта")
		
		#ищем лифт в сцене
		var lift = get_tree().get_first_node_in_group("lift")
		if lift and lift.has_method("start_lift"):
			lift.start_lift()
		else:
			print("Ошибка: лифт не найден!")
	#else:
		#interaction_triggered.emit()
		
	elif dialog_id != "":
		if dialog_id == "panel" and panel_already_activated:
			print("Панель уже была активирована, пропускаем")
			return
		
		print("Пытаемся запустить диалог: ", dialog_id)
		DialogManager.start_dialog(dialog_id)
		interaction_triggered.emit()
		
		if dialog_id == "panel":
			panel_already_activated = true
			print("Панель помечена как активированная")
		
		if is_final_trigger:
			while DialogManager.is_dialog_active:
				await get_tree().create_timer(0.1).timeout
			
			var hton_scene = null
			
			for node in get_tree().current_scene.get_children():
				if node.name == "HtonScene" or node.name == "hton_scene":
					hton_scene = node
					break
			
			if hton_scene:
				var player = hton_scene.get_node("Player")
				if player:
					var camera = player.get_node("Camera2D")
					if camera:
						camera.do_camera_zoom(true)
	#else:
		#interaction_triggered.emit()
#!!!!!!!!!!!!!!!!!!!!!!!!

func _on_body_entered(body: Node):
	# Проверяем, что вошел игрок (по имени или группе)
	if body.name == "Player":
		#print("Игрок вошел цццв зону взаимодействия: ", name)
		
		# Отправляем сигнал в GameStateManager
		player_entered_interaction_zone.emit(name)
		
		# Также можно напрямую эмитить в GSM, если он подключен
		if GameStateManager:
			GameStateManager.emit_signal("player_entered_interaction_zone", name)
		$AnimatedSprite2D/ColorRect.show()
		
		
		if is_gameplay_trigger and not camera_already_triggered:
			camera_already_triggered = true
			await get_tree().create_timer(0.5).timeout
			
			var camera = body.get_node("Camera2D")
			if camera:
				camera.do_camera_zoom(false)

func _on_body_exited(body: Node):
	# Проверяем, что вышел игрок
	if body.name == "Player":
		#print("Игрокввв вышел из зоны взаимодействия: ", name)
		
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
		if body.name == "Player":
			return true
	return false

func _exit_tree():
	# Отключаем сигналы при удалении объекта
	if area_2d and area_2d.is_connected("body_entered", _on_body_entered):
		area_2d.disconnect("body_entered", _on_body_entered)
	if area_2d and area_2d.is_connected("body_exited", _on_body_exited):
		area_2d.disconnect("body_exited", _on_body_exited)
