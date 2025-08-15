extends Area2D

signal game_over()

func onBodyEntered(body: Node2D) -> void:
	if body.is_in_group("obstacles"):
		if body.has_method("fly_off"):
			body.fly_off()
	else:
		game_over.emit()
