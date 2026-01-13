extends Node2D



func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/trenchbroom2_test_level.tscn")


func _on_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/world.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
