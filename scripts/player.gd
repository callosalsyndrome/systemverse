extends CharacterBody2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 


#signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
#signal player_initiated_cutscene()
#signal player_initiated_combat()
#signal checkpoint_reached()

@export var speed: int = 150
var last_direction = ""
var is_moving = false

func _ready() -> void:
	add_to_group("player")
	# Сигнализируем что Player готов
	get_tree().call_group("player_ready_listeners", "_on_player_ready", self)
var is_being_carried = false  #переносит ли лифт игрока

func _physics_process(_delta):
	
	#отключаем управление в лифте
	if is_being_carried:
		#чтобы красиво стоял в лифе
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.frame = 1
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_direction = Vector2.ZERO
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
	
	if Input.is_action_pressed("speed"):
		speed = 250
	else:
		speed = 150
	
	# Двигаем персонажа
	#position += input_direction * speed * _delta #ЛОМАЕТ ВСЮ ФИЗИКУ СТОЛКНОВЕНИЙ

	
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
