extends Area2D

func onBodyEntered(body: Node2D) -> void:
	if body.is_in_group("obstacles"):
		if body.has_method("fly_off"):
			body.fly_off()
	else:
		GlobalInput.isPauseShortcutAllowed = false
		GameState.removePlayer(GameState.getPlayer())
