extends Area2D

signal note_hit()

func _physics_process(delta: float) -> void:
	var mouse := get_viewport().get_mouse_position()
	$".".position.y = mouse.y

func onBodyEntered(body: Node2D) -> void:
	body.queue_free()
	note_hit.emit()
