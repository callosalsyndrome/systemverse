extends Node2D

@onready var save_animation: Control = $SaveAnimation
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

# Длительность анимации появления/скрытия в секундах
const FADE_DURATION := 0.5

func _ready():
	# Скрываем все элементы при старте
	hide_elements_instantly()
	show_scene()

func show_scene():
	# Плавное появление элементов
	fade_in_elements()

func hide_scene():
	# Плавное скрытие элементов
	fade_out_elements()

func fade_in_elements():
	# Сначала включаем видимость (но с прозрачностью 0)
	save_animation.modulate = Color(1, 1, 1, 0)
	animated_sprite.modulate = Color(1, 1, 1, 0)
	label.modulate = Color(1, 1, 1, 0)
	
	save_animation.visible = true
	animated_sprite.visible = true
	label.visible = true
	
	# Анимация появления
	var tween = create_tween().set_parallel(true)
	tween.tween_property(save_animation, "modulate:a", 1.0, FADE_DURATION)
	tween.tween_property(animated_sprite, "modulate:a", 1.0, FADE_DURATION)
	tween.tween_property(label, "modulate:a", 1.0, FADE_DURATION)
	
	# Если нужно, можно добавить небольшую задержку между элементами
	# Для последовательного появления используйте set_parallel(false)

func fade_out_elements():
	var tween = create_tween().set_parallel(true)
	tween.tween_property(save_animation, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_property(animated_sprite, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_property(label, "modulate:a", 0.0, FADE_DURATION)
	
	# После завершения анимации скрываем элементы
	await tween.finished
	hide_elements_instantly()

func hide_elements_instantly():
	save_animation.visible = false
	animated_sprite.visible = false
	label.visible = false
	
	# Сбрасываем прозрачность
	save_animation.modulate = Color(1, 1, 1, 1)
	animated_sprite.modulate = Color(1, 1, 1, 1)
	label.modulate = Color(1, 1, 1, 1)
