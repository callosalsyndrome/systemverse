extends Area2D

class_name Lift

@onready var animated_sprite = $AnimatedSprite2D

var player_inside = false
var is_moving = false
var is_active = false  # Активирован ли лифт
var lift_speed = 100.0
var target_y = 0.0
