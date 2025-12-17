# deleting_confirm.gd
extends ColorRect

signal confirmed()
signal cancelled()

@onready var stay_button: Button = $Stay_Button
@onready var delete_button: Button = $Delete_Button
@onready var background_blocker: ColorRect = $ColorRect  # Затемняющий фон

func _ready():
	hide()
	
	# Настраиваем затемняющий фон
	if background_blocker:
		background_blocker.color = Color(0, 0, 0, 0.5)  # Полупрозрачный черный
		# Делаем фон блокирующим события мыши
		background_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	
	if stay_button:
		print("Stay_Button найден, подключаем...")
		stay_button.pressed.connect(_on_stay_button_pressed)
	if delete_button:
		print("Delete_Button найден, подключаем...")
		delete_button.pressed.connect(_on_delete_button_pressed)

func show_confirm():
	show()
	print("Окно подтверждения показано")
	
	# Блокируем взаимодействие с фоном
	_set_interaction(false)
	
	# Устанавливаем высокий z_index
	z_index = 1000
	
	if stay_button:
		stay_button.grab_focus()

func hide_confirm():
	hide()
	# Восстанавливаем взаимодействие
	_set_interaction(true)

# Включение/выключение взаимодействия с элементами под окном
func _set_interaction(enabled: bool):
	# Находим и блокируем все кнопки в родительской сцене
	var parent = get_parent()
	if parent:
		for child in parent.get_children():
			if child != self and child is BaseButton:
				child.disabled = not enabled

func _on_stay_button_pressed():
	print("Кнопка Stay нажата!")
	cancelled.emit()
	hide_confirm()

func _on_delete_button_pressed():
	print("Кнопка Delete нажата!")
	confirmed.emit()
	hide_confirm()
