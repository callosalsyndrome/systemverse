extends Node

func load_dialog(dialog_id: String) -> Array:
	var file_path = "res://dialogs/%s.json" % dialog_id
	print("Поиск файла: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			print("Содержимое json: ", data)
			return data.lines
		else:
			print("Ошибка парсинга json: ", error)
	else:
		print("Файл не найден: ", file_path)
	return []

var current_dialog: Array = []
var current_line: int = 0
var is_dialog_active: bool = false
var dialog_ui = null

func start_dialog(dialog_id: String):
	print("ЗАПУСК ДИАЛОГА: ", dialog_id)
	
	current_dialog = load_dialog(dialog_id)
	if current_dialog.size() > 0:
		if dialog_ui == null or not is_instance_valid(dialog_ui):
			var scene = load("res://scenes/dialog_ui.tscn")
			dialog_ui = scene.instantiate()
			get_tree().root.add_child(dialog_ui)
			dialog_ui.hide()
			print("DialogUI создан")
			
		current_line = 0
		is_dialog_active = true
		dialog_ui.show()
		show_current_line()  #показывается первая реплика
		
		get_viewport().set_input_as_handled() #блокировка ввода, чтобы InteractableObject не обработал это же нажатие
	else:
		print("Не удалось загрузить json")

func show_current_line():
	if current_line < current_dialog.size():
		var line_data = current_dialog[current_line]
		dialog_ui.display_line(line_data)
	else:
		end_dialog()

func next_line():
	if is_dialog_active:
		current_line += 1
		show_current_line()

func end_dialog():
	is_dialog_active = false
	current_dialog = []
	current_line = 0
	dialog_ui.hide()
	print("Диалог завершён")

func _input(event):
	#нажатие Z обрабатывается только если диалог активен
	if is_dialog_active and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()  #блокировка дальнейшей обработки
		next_line()
