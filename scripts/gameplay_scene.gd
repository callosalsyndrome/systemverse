extends Node2D

# я еще не уверена как будет реализовываться геймплей. 
# там определенно будет сцена игрока + tilemap-ы локаций
# в общем пока достаточно релизовать открытие сцены через сигналы + движение игрока в ней

signal game_started()

func _ready():
	print("GP: Я - ", name)
	# Геймплейная сцена добавляет СЕБЯ в группу
	add_to_group("gameplay_scene")  
	_on_game_started()
	
func _on_game_started():
	print("GP: Game world started!")
	print("GP: Эмитим (выполняем) сигнал game_started")
	game_started.emit()
	
