extends Node

func _process(delta):
	if Input.is_action_just_pressed("reload"):
		get_tree().change_scene_to_file("res://gameplay/00_intro1.tscn")
