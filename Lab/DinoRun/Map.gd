extends Node2D
@export var speed: int = 500

func _ready() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	position.x -= delta * speed
	print(position.x)

func _process(delta: float) -> void:
	position.x -= delta * speed
	print(position.x)
