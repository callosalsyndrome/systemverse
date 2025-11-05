#extends Node2D
extends CharacterBody2D

# для начала будет достаточно реализовать правильно движение + зону, в которой игроку будет 
# доступно взаимодействие с предметами. 


signal player_initiated_dialogue() #диалог с нпс или взаимодействие с предметом
signal player_initiated_cutscene()
signal player_initiated_combat()
signal checkpoint_reached()

@export var speed: int = 200
@export var interaction_area: Area2D  #пока не надо

func _physics_process(_delta):
	var input_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1
		$AnimatedSprite2D.animation = "horisonral_right"
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
		$AnimatedSprite2D.animation = "horisonral_left"
	
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
		$AnimatedSprite2D.animation = "vertical_down"
	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
		$AnimatedSprite2D.animation = "vertical_up"
	
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.flip_h = false
		
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.animation = "diagonal_down"
		$AnimatedSprite2D.flip_h = true
	
	#на будущее
	#if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		#$AnimatedSprite2D.animation = "diagonal_up"
		#$AnimatedSprite2D.flip_h = false 
		#
	#if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		#$AnimatedSprite2D.animation = "diagonal_up"
		#$AnimatedSprite2D.flip_h = true
	
	#нормализация для диагоналей, применение скорости
	if input_direction != Vector2.ZERO:
		input_direction = input_direction.normalized()
		velocity = input_direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
