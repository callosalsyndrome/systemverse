extends CanvasLayer

func _ready():
	$Panel/Button.connect("pressed", _on_button_pressed)

func _on_button_pressed():
	var gsm = get_node("/root/GameStateManager")
	if gsm and gsm.has_method("_connect_to_menu"):
		gsm._connect_to_menu()
	
	get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
