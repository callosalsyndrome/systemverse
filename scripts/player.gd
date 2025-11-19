extends CharacterBody2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 


signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
signal player_initiated_cutscene()
signal player_initiated_combat()
signal checkpoint_reached()

@export var speed: int = 200
var last_direction = ""
var is_moving = false

func _physics_process(_delta):
	var input_direction = Vector2.ZERO
	is_moving = false
	
	#право
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
		$AnimatedSprite2D.play("horisontal_right")
		$AnimatedSprite2D.flip_h = false
		last_direction = "right"
		is_moving = true
	
	#лево
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
		$AnimatedSprite2D.play("horisontal_right")
		$AnimatedSprite2D.flip_h = true
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
	
	#низ право
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.flip_h = false
		last_direction = "down_right"
		is_moving = true
	
	#низ лево
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.flip_h = true
		last_direction = "down_left"
		is_moving = true
	
	#верх право
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.animation = "diagonal_up"
		$AnimatedSprite2D.flip_h = false
		last_direction = "up_right"
		is_moving = true
	
	#верх лево
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.animation = "diagonal_up"
		$AnimatedSprite2D.flip_h = true
		last_direction = "up_left"
		is_moving = true
	
	#попытка в остановку анимации
	if (is_moving == false):
		match last_direction:
			"down":
				$AnimatedSprite2D.animation = "vertical_down_stand"
			"up":
				$AnimatedSprite2D.animation = "vertical_up_stand"
			"right":
				$AnimatedSprite2D.animation = "horisontal_right_stand"
				$AnimatedSprite2D.flip_h = false
			"left":
				$AnimatedSprite2D.animation = "horisontal_right_stand"
				$AnimatedSprite2D.flip_h = true
			#"down_right":
				#$AnimatedSprite2D.animation = ""
				#$AnimatedSprite2D.flip_h = false
			#"down_left":
				#$AnimatedSprite2D.animation = ""
				#$AnimatedSprite2D.flip_h = true
			#"up_right":
				#$AnimatedSprite2D.animation = ""
				#$AnimatedSprite2D.flip_h = false
			#"up_left":
				#$AnimatedSprite2D.animation = ""
				#$AnimatedSprite2D.flip_h = true
	
	#нормализация для диагоналей, применение скорости
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		velocity = input_direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	
