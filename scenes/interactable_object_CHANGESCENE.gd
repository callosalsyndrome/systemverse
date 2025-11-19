extends "res://scripts/interactable_object.gd"

func handle_interaction():
	print("Взаимодействие с объектом:", name)
	interaction_started.emit(self)
	perform_interaction()
	
func perform_interaction(): #переопределяется для дочерних классов
	print("Взаимодействие с ", name)
	interaction_triggered.emit()

# оно вообще не запускается лол.
