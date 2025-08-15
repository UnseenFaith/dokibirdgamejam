extends Area2D

signal note_hit()

func _process(delta: float) -> void:
	var mouse := get_viewport().get_mouse_position()
	$".".position.y = clamp(mouse.y, 139, 256)

func onBodyEntered(body: Node2D) -> void:
	body.queue_free()
	$AnimatedSprite2D.play("chomp")
	$AudioStreamPlayer.play()
	note_hit.emit()


func onAnimatedSprite2d_animationFinished() -> void:
	$AnimatedSprite2D.play("open")
