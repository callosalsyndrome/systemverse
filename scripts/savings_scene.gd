extends Node2D

@onready var save_slot_1: Button = $SaveSlot
@onready var save_slot_2: Button = $SaveSlot2
@onready var save_slot_3: Button = $SaveSlot3

signal first_slot_selected()
signal second_slot_selected()
signal third_slot_selected()

#signal delete_first_slot_selected()
#signal delete_second_slot_selected()
#signal delete_third_slot_selected()

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
	print("SVS: Эмитим (выполняем) сигнал delete_first_slot_selected")
	SaveLoadManager.section_name = "first_slot" 
	SaveLoadManager.delete_section()

func _on_delete_second_slot_selected() -> void:
	print("SVS: Эмитим (выполняем) сигнал _on_delete_second_slot_selected")
	SaveLoadManager.section_name = "second_slot" 
	SaveLoadManager.delete_section()
	
func _on_delete_third_slot_selected() -> void:
	print("SVS: Эмитим (выполняем) сигнал _on_delete_third_slot_selected")
	SaveLoadManager.section_name = "third_slot" 
	SaveLoadManager.delete_section()
