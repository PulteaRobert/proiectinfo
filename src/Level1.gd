extends Node2D

func _ready():
	yield(get_tree().create_timer(1.0), "timeout") 
	$Area2D/CollisionShape2D.disabled = false


func _on_Area2D_body_entered(body):
	$Congrats.play()
