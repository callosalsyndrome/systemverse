extends Node2D

# сцена сохранений открывается после нажатия кнопки "начать игру"
# содержит в сете 3 слота сохранений
# после выбора слота уже начинается игра
# пока хз как реализовать

# сцена содержит в себе сцену слота сохранения - у нее отдельный скрипт. 
# менять каждый слот придется через код, но они будут сохранять общие свойства, которые описаны в сцене save_slot
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

func _on_first_slot_selected() -> void:
	print("SVS: Эмитим (выполняем) сигнал first_slot_selected")
	first_slot_selected.emit()
	
func _on_second_slot_selected() -> void:
	print("SVS: Эмитим (выполняем) сигнал second_slot_selected")
	second_slot_selected.emit()
	
func _on_third_slot_selected() -> void:
	print("SVS: Эмитим (выполняем) сигнал third_slot_selected")
	third_slot_selected.emit()
