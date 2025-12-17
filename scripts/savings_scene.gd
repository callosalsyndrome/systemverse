extends Node2D

@onready var save_slot_1: Button = $SaveSlot
@onready var save_slot_2: Button = $SaveSlot2
@onready var save_slot_3: Button = $SaveSlot3


signal first_slot_selected()
signal second_slot_selected()
signal third_slot_selected()


func _ready():
	print("SVS: Я - ", name)
	add_to_group("savings_scene")
	save_slot_1.pressed.connect(_on_first_slot_selected)
	save_slot_2.pressed.connect(_on_second_slot_selected)
	save_slot_3.pressed.connect(_on_third_slot_selected)
	
	var button_1 = get_node("SaveSlot/DeleteButton")
	button_1.pressed.connect(_on_delete_first_slot_selected)
	var button_2 = get_node("SaveSlot2/DeleteButton")
	button_2.pressed.connect(_on_delete_second_slot_selected)
	var button_3 = get_node("SaveSlot3/DeleteButton")
	button_3.pressed.connect(_on_delete_third_slot_selected)

func _on_first_slot_selected() -> void:
	first_slot_selected.emit()
	
func _on_second_slot_selected() -> void:
	second_slot_selected.emit()
	
func _on_third_slot_selected() -> void:
	third_slot_selected.emit()

func _on_delete_first_slot_selected() -> void:
	print("SVS: Запрашиваем подтверждение удаления первого слота")
	# Вместо прямого удаления, запрашиваем подтверждение
	SaveLoadManager.request_delete_confirmation("first_slot", Callable(self, "_perform_delete_first_slot"))

func _on_delete_second_slot_selected() -> void:
	print("SVS: Запрашиваем подтверждение удаления второго слота")
	SaveLoadManager.request_delete_confirmation("second_slot", Callable(self, "_perform_delete_second_slot"))
	
func _on_delete_third_slot_selected() -> void:
	print("SVS: Запрашиваем подтверждение удаления третьего слота")
	SaveLoadManager.request_delete_confirmation("third_slot", Callable(self, "_perform_delete_third_slot"))

# Функции, которые будут вызваны только после подтверждения
func _perform_delete_first_slot() -> void:
	print("SVS: Выполняем удаление первого слота")
	SaveLoadManager.section_name = "first_slot" 
	SaveLoadManager.delete_section()
	# Здесь можно добавить обновление UI, например, скрыть или изменить отображение слота

func _perform_delete_second_slot() -> void:
	print("SVS: Выполняем удаление второго слота")
	SaveLoadManager.section_name = "second_slot" 
	SaveLoadManager.delete_section()

func _perform_delete_third_slot() -> void:
	print("SVS: Выполняем удаление третьего слота")
	SaveLoadManager.section_name = "third_slot" 
	SaveLoadManager.delete_section()
