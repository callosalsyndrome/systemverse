extends CanvasLayer

# просто открывается поверх геймплея
@onready var resume_button: Button = $Control/resume_button
@onready var exit_to_menu_button: Button = $Control/exit_to_menu_button

signal resume_button_pressed
signal exit_to_menu_button_pressed

func _ready():
	print("PS: Я - ", name)
	print("Pause scene visible: ", visible)
	
	var control_node = $Control
	var camera = get_viewport().get_camera_2d()
	if control_node and camera:
		var camera_center = camera.global_position
		var viewport_size = get_viewport().get_visible_rect().size
		control_node.position = camera_center - viewport_size / 2
		control_node.size = viewport_size
		
	add_to_group("pause_scene")
	resume_button.pressed.connect(_on_resume_button_pressed)
	exit_to_menu_button.pressed.connect(_on_exit_to_menu_button_pressed)
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_resume_button_pressed() -> void:
	print("Нажата кнопка Продолжить")
	resume_button_pressed.emit()

func _on_exit_to_menu_button_pressed() -> void:
	print("Нажата кнопка Выйти")
	get_tree().paused = false
	exit_to_menu_button_pressed.emit()
