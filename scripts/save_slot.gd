extends Button

@export var slot_number: int
@export var percentage_of_progress: int
@onready var number_label = $slot_number_label

func _ready():
	number_label.text = "Слот сохранения №%d" %slot_number

# Первая кнопка
# не удалять

func _on_button_pressed() -> void:
	pass # Replace with function body.
