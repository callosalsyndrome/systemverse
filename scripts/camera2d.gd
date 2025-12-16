extends Camera2D

var zoom_done = false
var original_zoom = Vector2(1, 1)

var original_position = Vector2.ZERO

var gameplay_duration: float = 2.0  #скорость для геймплей
var final_duration: float = 9.0    #скорость для финала (медленнее)

func do_camera_zoom(is_final: bool = false):
	if zoom_done:
		return
	
	zoom_done = true
	
	#блокировка игрока
	var player = get_parent()
	print("   Игрок:", player.name)
	player.set_process_input(false)
	player.set_physics_process(false)
	
	if not is_final:
		original_zoom = zoom
		original_position = position
	
	#отъезжаем
	var tween = create_tween()
	
	if is_final:
		var target_coords = Vector2(1436, -538)
		tween.tween_property(self, "zoom", Vector2(0.6, 0.6), final_duration)
		tween.parallel().tween_property(self, "global_position", target_coords, final_duration)
	else:
		var target_coords = Vector2(899, 234)
		tween.tween_property(self, "zoom", Vector2(1, 1), gameplay_duration)
		tween.parallel().tween_property(self, "global_position", target_coords, gameplay_duration)
	
	await tween.finished
	await get_tree().create_timer(3.0).timeout
	
	if is_final:
		var final = load("res://scenes/final_scene.tscn")
		get_tree().current_scene.add_child(final.instantiate())
	else:
		tween = create_tween()
		tween.tween_property(self, "zoom", original_zoom, gameplay_duration)
		tween.parallel().tween_property(self, "position", original_position, gameplay_duration)  # <--- Возвращаемся к исходной позиции
		
		await tween.finished
		player.set_process_input(true)
		player.set_physics_process(true)
		zoom_done = false
