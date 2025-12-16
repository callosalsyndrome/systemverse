extends CharacterBody2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 

#signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
#signal player_initiated_cutscene()
#signal player_initiated_combat()
#signal checkpoint_reached()

#звуки
@export var step_sound: AudioStream  # Перетащите сюда звуковой файл в редакторе
@export var step_interval: float = 0.3  # Интервал между шагами в секундах
@export var run_step_interval: float = 0.2  # Интервал при беге
@export var step_volume_db: float = -10.0  # Громкость шагов в децибелах (-80 до 24)
@export var run_volume_db: float = -5.0  # Громкость шагов при беге
@export var volume_variation: float = 2.0  # Вариация громкости (разброс в децибелах)

# Таймер для шагов
var step_timer: float = 0.0
var current_step_interval: float = 0.3
var current_volume_db: float = -10.0

@export var speed: int = 150
var last_direction = ""
var is_moving = false
var is_sound_playing = false

func _ready() -> void:
	add_to_group("player")
	# Сигнализируем что Player готов
	get_tree().call_group("player_ready_listeners", "_on_player_ready", self)
	# Настраиваем звук шагов
	if $AudioStreamPlayer2D.stream == null and step_sound != null:
		$AudioStreamPlayer2D.stream = step_sound
	
	# Устанавливаем начальную громкость
	$AudioStreamPlayer2D.volume_db = step_volume_db
	current_volume_db = step_volume_db

var is_being_carried = false  #переносит ли лифт игрока

func _physics_process(delta):
	
	# Отключаем управление в лифте
	if is_being_carried:
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1
		velocity = Vector2.ZERO
		move_and_slide()
		stop_footsteps()  # Останавливаем звук шагов в лифте
		return
	
	var input_direction = Vector2.ZERO
	var was_moving = is_moving
	is_moving = false
	
	# Сначала проверяем диагональные движения
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		input_direction.x += 1
		input_direction.y += 1
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "diagonal_down"
		last_direction = "down_right"
		is_moving = true
	
	elif Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		input_direction.x -= 1
		input_direction.y += 1
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.animation = "diagonal_down"
		last_direction = "down_left"
		is_moving = true
	
	elif Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		input_direction.x += 1
		input_direction.y -= 1
		$AnimatedSprite2D.flip_h = false
		$AnimatedSprite2D.animation = "diagonal_up"
		last_direction = "up_right"
		is_moving = true
	
	elif Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		input_direction.x -= 1
		input_direction.y -= 1
		$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.animation = "diagonal_up"
		last_direction = "up_left"
		is_moving = true
	
	# Затем проверяем простые направления
	else:
		#право
		if Input.is_action_pressed("move_right"):
			input_direction.x += 1
			$AnimatedSprite2D.play("horisontal")
			$AnimatedSprite2D.flip_h = false
			last_direction = "right"
			is_moving = true
		
		#лево
		if Input.is_action_pressed("move_left"):
			input_direction.x -= 1
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("horisontal")
			last_direction = "left"
			is_moving = true
		
		#низ
		if Input.is_action_pressed("move_down"):
			input_direction.y += 1
			$AnimatedSprite2D.play("vertical_down")
			last_direction = "down"
			is_moving = true
		
		#верх
		if Input.is_action_pressed("move_up"):
			input_direction.y -= 1
			$AnimatedSprite2D.play("vertical_up")
			last_direction = "up"
			is_moving = true
	
	# Нормализуем вектор направления для диагонального движения
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	# Устанавливаем скорость и настройки шагов в зависимости от режима
	if Input.is_action_pressed("speed"):
		speed = 250
		current_step_interval = run_step_interval
		current_volume_db = run_volume_db
	else:
		speed = 150
		current_step_interval = step_interval
		current_volume_db = step_volume_db
	
	# Двигаем персонажа
	velocity = input_direction * speed
	move_and_slide()
	
	#попытка в остановку анимации
	if not is_moving:
		match last_direction:
			"down":
				$AnimatedSprite2D.animation = "vertical_down"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 1
			"up":
				$AnimatedSprite2D.animation = "vertical_up"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 4
			"right":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.animation = "horisontal"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 7
			"left":
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.animation = "horisontal"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 7
			"up_right":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.animation = "diagonal_up"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 0
			"up_left":
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.animation = "diagonal_up"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 0
			"down_right":
				$AnimatedSprite2D.flip_h = false
				$AnimatedSprite2D.animation = "diagonal_down"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 1
			"down_left":
				$AnimatedSprite2D.flip_h = true
				$AnimatedSprite2D.animation = "diagonal_down"
				$AnimatedSprite2D.stop()
				$AnimatedSprite2D.frame = 1
	manage_footsteps(delta, was_moving)
				
func manage_footsteps(delta: float, was_moving: bool):
	# Если игрок движется
	if is_moving:
		# Увеличиваем таймер
		step_timer += delta
		
		# Если пришло время для следующего шага
		if step_timer >= current_step_interval:
			play_footstep()
			step_timer = 0.0
		
		# Если только начали движение, воспроизводим шаг сразу
		elif not was_moving:
			play_footstep()
			step_timer = 0.0
	else:
		step_timer = 0.0
		stop_footsteps()

func play_footstep():
	# Воспроизводим звук шага
	if $AudioStreamPlayer2D.stream != null:
		# Устанавливаем громкость с вариацией для естественности
		var volume_variation_amount = randf_range(-volume_variation, volume_variation)
		$AudioStreamPlayer2D.volume_db = current_volume_db + volume_variation_amount
		
		# Случайное изменение высоты тона для естественности
		$AudioStreamPlayer2D.pitch_scale = randf_range(0.9, 1.1)
		
		$AudioStreamPlayer2D.play()
		is_sound_playing = true

func stop_footsteps():
	if $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
	is_sound_playing = false
	step_timer = 0.0

# Дополнительные функции для управления звуком извне

func set_step_sound(new_sound: AudioStream):
	"""Установить новый звук шагов"""
	$AudioStreamPlayer2D.stream = new_sound

func set_step_interval(walk_interval: float, run_interval: float):
	"""Установить интервалы шагов"""
	step_interval = walk_interval
	run_step_interval = run_interval

func set_step_volume(walk_volume: float, run_volume: float):
	"""Установить громкость шагов"""
	step_volume_db = walk_volume
	run_volume_db = run_volume
	
	# Обновляем текущую громкость, если не бежим
	if not Input.is_action_pressed("speed"):
		current_volume_db = step_volume_db
		$AudioStreamPlayer2D.volume_db = step_volume_db

func set_volume_variation(variation: float):
	"""Установить разброс громкости"""
	volume_variation = clamp(variation, 0.0, 12.0)  # Ограничиваем разумными пределами

func mute_footsteps(mute: bool):
	"""Включить/выключить звук шагов"""
	if mute:
		$AudioStreamPlayer2D.volume_db = -80.0  # Полная тишина
	else:
		$AudioStreamPlayer2D.volume_db = current_volume_db

func fade_footsteps(target_volume: float, duration: float = 1.0):
	"""Плавное изменение громкости шагов"""
	var tween = create_tween()
	tween.tween_property($AudioStreamPlayer2D, "volume_db", target_volume, duration)
