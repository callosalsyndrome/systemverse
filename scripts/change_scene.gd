extends Node

var next_world
var next_world_name: String
var last_world_name : String

@onready var current_world: Node2D = $GameplayScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("CS: Я - ", name)
	add_to_group("player_ready_listeners")
	current_world.connect("world_changed", handle_world_changed)
	
	if SaveLoadManager.flag == false:
		next_world = load("res://scenes/" + SaveLoadManager.current_scene_name + ".tscn").instantiate()
		next_world.z_index = -10
		add_child(next_world) 
		next_world.connect("world_changed", handle_world_changed)
		current_world.queue_free()
		current_world = next_world
		current_world.z_index = 0
		current_world.name = SaveLoadManager.current_scene_name
		SaveLoadManager.flag = true
	if SaveLoadManager.current_scene_name != "gameplay_scene":
		#handle_world_changed(last_world_name)
		print()
	elif SaveLoadManager.current_scene_name == "gameplay_scene":
		var player = get_tree().get_first_node_in_group("player")
		if SaveLoadManager.position != null:
			print("Позиция игрока н установлена: ", player.position)
			player.position = SaveLoadManager.position
			print("Позиция игрока н1 установлена: ", player.position)
		else: 
			print("не установилсся player")
		
	

func _on_player_ready(player: Node):
	if SaveLoadManager.position != null:
		if SaveLoadManager.flag:
				SaveLoadManager.position = player.position
				print("Позиция Г игрока сохранена: ", player.position)
		print("Позиция з игрока установлена: ", player.position)
		player.position = SaveLoadManager.position
		print("Позиция з1 игрока установлена: ", player.position)
	
func handle_world_changed(current_world_name: String):
	 
	match current_world_name:
		"gameplay_scene":
			next_world_name = "lab_gameplay_scene" 
		"GameplayScene":
			next_world_name = "lab_gameplay_scene" 
		"lab_gameplay_scene":
			next_world_name = "lab_lift_gameplay_scene"
		"LabGameplayScene":
			next_world_name = "lab_lift_gameplay_scene"
		"lab_lift_gameplay_scene":
			next_world_name = "hton_scene"
		"LabLiftGameplayScene":
			next_world_name = "hton_scene"
			
	
	next_world = load("res://scenes/" + next_world_name + ".tscn").instantiate()
	next_world.z_index = -10
	animation_player.play("fade_in") 
	await animation_player.animation_finished
	add_child(next_world) 
	next_world.connect("world_changed", handle_world_changed)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_in":
		
			animation_player.play("fade_out")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"fade_out":
			current_world.queue_free()
			current_world = next_world
			current_world.z_index = 0
			
			SaveLoadManager.current_scene_name = next_world_name
			var player = get_tree().get_first_node_in_group("player")
			SaveLoadManager.flag = true
			
