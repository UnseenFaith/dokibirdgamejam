extends Area2D

signal note_hit()

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed(GlobalInput.Actions.moveUp):
		position.y -= delta * 200
	if Input.is_action_pressed(GlobalInput.Actions.moveDown):
		position.y += delta * 200
		
	position.y = clamp(position.y, 139, 256)
	#var mouse := get_viewport().get_mouse_position()
	#$".".position.y = clamp(mouse.y, 139, 256)

func onBodyEntered(body: Node2D) -> void:
	body.queue_free()
	$AnimatedSprite2D.play("chomp")
	$AudioStreamPlayer.play()
	note_hit.emit()


func onAnimatedSprite2d_animationFinished() -> void:
	$AnimatedSprite2D.play("open")
