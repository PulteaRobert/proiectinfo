extends Node2D


func _on_Level1_body_entered(body):
	SceneChanger.change_scene("res://src/Level1.tscn", 0.5)
