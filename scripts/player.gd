extends CharacterBody2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 


signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
signal player_initiated_cutscene()
signal player_initiated_combat()
signal checkpoint_reached()

@export var speed: int = 150
var last_direction = ""
var is_moving = false

func _ready() -> void:
	add_to_group("player")
	# Сигнализируем что Player готов
	get_tree().call_group("player_ready_listeners", "_on_player_ready", self)

func _physics_process(_delta):
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
	
	# Двигаем персонажа
	position += input_direction * speed * _delta
	
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
	
	
