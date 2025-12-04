extends Node

var next_world

@onready var current_world: Node2D = $GameplayScene
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	print("CS: Я - ", name)
	current_world.connect("world_changed", handle_world_changed)

func handle_world_changed(current_world_name: String):
	var next_world_name: String
	 
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
			return
	
	next_world = load("res://scenes/" + next_world_name + ".tscn").instantiate()
	next_world.z_index = -10
	animation_player.play("fade_in") 
	await animation_player.animation_finished
	add_child(next_world) 
	next_world.connect("world_changed", handle_world_changed)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fade_in":
			#current_world.queue_free()
			#current_world = next_world
			#current_world.z_index = 0
			#next_world = null
			animation_player.play("fade_out")

func _on_animation_player_animation_started(anim_name: StringName) -> void:
	match anim_name:
		"fade_out":
			current_world.queue_free()
			current_world = next_world
			current_world.z_index = 0
			#next_world = null
