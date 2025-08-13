extends Node2D

signal note_missed()

@export var lane: int = 0
@export var speed: float = 200.0
@export var hit_zone_x: float = 200.0

func _process(delta):
	position.x -= speed * delta
	if position.x <= 0:
		note_missed.emit()
		queue_free()
