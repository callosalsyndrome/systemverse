extends Node2D

@export var background_music: AudioStream
@onready var controlling_guide = $"Player/КакРулить"

signal game_started()
signal world_changed(world_name)

# Таймер для скрытия подсказки
var guide_timer: Timer = null

func _ready():
	print("GP: Я - ", name)
	add_to_group("player_ready_listeners")
	
	# Скрываем подсказку сразу
	if controlling_guide:
		controlling_guide.hide()
	
	# Создаем и настраиваем таймер
	setup_guide_timer()
	
	# Показываем подсказку на 10 секунд
	show_guide_for_duration(10.0)
	
	_on_game_started()
	
	if background_music:
		print("GP: Отправляю музыку в BackgroundMusic")

func setup_guide_timer() -> void:
	# Создаем таймер
	guide_timer = Timer.new()
	guide_timer.one_shot = true
	guide_timer.autostart = false
	guide_timer.timeout.connect(_on_guide_timer_timeout)
	add_child(guide_timer)

func show_guide_for_duration(duration: float) -> void:
	if controlling_guide:
		# Показываем подсказку
		controlling_guide.show()
		print("Подсказка показана")
		
		# Запускаем таймер на указанное время
		if guide_timer:
			guide_timer.start(duration)
	else:
		print("Ошибка: controlling_guide не найден")

func hide_guide() -> void:
	if controlling_guide:
		controlling_guide.hide()
		print("Подсказка скрыта")

func _on_guide_timer_timeout() -> void:
	# Таймер истек, скрываем подсказку
	hide_guide()

func _on_game_started():
	game_started.emit()

func get_background_music() -> AudioStream:
	return background_music

var entered = false #Находимся ли мы в зоне

@export var world_name: String = "gameplay_scene" 

func _process(_delta):
	if entered == true: 
		if Input.is_action_just_pressed("interact"):
			world_name = name
			world_changed.emit(world_name) 

func _on_interactable_object_player_entered_interaction_zone(_object_name: Variant) -> void:
	entered = true
	
func _on_interactable_object_player_exited_interaction_zone(_object_name: Variant) -> void:
	entered = false
