extends Node2D


func _on_Area2D_body_entered(body):
	SceneChanger.change_scene("res://src/Level1.tscn", 0.5)
