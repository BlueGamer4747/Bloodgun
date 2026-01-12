extends Node3D

var is_colliding : CollisionShape3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_colliding:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
