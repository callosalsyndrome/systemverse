extends Node2D

signal game_started()
signal world_changed(world_name)

func _ready():
	print("GP: Я - ", name)
	add_to_group("player_ready_listeners")
	_on_game_started()
	
func _on_game_started():
	game_started.emit()

var entered = false #Находимся ли мы в зоне

@export var world_name: String = "gameplay_scene" 

func _process(_delta):
	if entered == true: 
		if Input.is_action_just_pressed("interact"):
			world_name = name
			world_changed.emit(world_name) 

func _on_interactable_object_player_entered_interaction_zone(_object_name: Variant) -> void:
	entered = true
func _on_interactable_object_player_exited_interaction_zone(_object_name: Variant) -> void:
	entered = false
	
