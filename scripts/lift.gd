extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

var is_moving = false
var player = null
var player_visible = true  #видимость игрока

func _ready():
	animated_sprite.play("closed")
	add_to_group("lift")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D and body.name == "Player":
		player = body
		print("Игрок вошел в лифт")

func start_lift():
	if is_moving:
		return
		
	is_moving = true
	print("=== СТАРТ ===")
	
	#1. двери открываются
	animated_sprite.play("opening")
	await animated_sprite.animation_finished
	
	#2. ищется игрок
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	if player:
		#тпхаем в лифт
		player.global_position = global_position
		# Сохраняем текущую видимость игрока
		player_visible = player_visible
		
		# Скрываем игрока (но оставляем в сцене для камеры)
		player.visible = false
		print("Игрок скрыт")
		
		#отключаем CollisionShape2D игрока
		var collision_shape = player.get_node("CollisionShape2D")
		if collision_shape:
			collision_shape.disabled = true
			print("CollisionShape2D игрока отключен")
		
		#отключаем управление
		player.is_being_carried = true
	#3. МЕНЯЕМ СПРАЙТ ЛИФТА НА ТОТ, ГДЕ ИГРОК ВНУТРИ
	animated_sprite.play("open")
	
	#3. ждём 1 секунду
	await get_tree().create_timer(1.0).timeout
	
	#4. двери закрываются
	animated_sprite.play("closing")
	await animated_sprite.animation_finished
	animated_sprite.play("closed2")
	
	#5
	print("Едем вверх")
	await move_up()
	
	#вроде как не надо но пусть будет на всякий случай хз
	##7
	#animated_sprite.play("opening")
	#await animated_sprite.animation_finished
	#
	##8. возврат управления
	#if player:
		#if player.has_method("stop_being_carried"):
			#player.stop_being_carried()
	#
	#is_moving = false
	#print("=== КОНЕЦ ===")

func move_up():
	print("Двигаем лифт и игрока...")
	
	#сохраняем ссылку на игрока
	var player_to_move = player
	
	#двигаем ВСЕГДА, если игрок есть
	for i in range(400): #800 (или 400*2) пикселей, доезжает до верха
		#двигаем лифт
		global_position.y -= 2
		
		#двигаем игрока (если он был найден)
		if player_to_move:
			player_to_move.global_position.y -= 2
		
		#небольшая пауза
		await get_tree().create_timer(0.01).timeout
	
	print("всё")
