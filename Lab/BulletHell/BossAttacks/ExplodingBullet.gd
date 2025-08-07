extends Node2D
@onready var timer := $Timer
var speed = 100
var dir = Vector2.LEFT
var bullet_enemy = preload("res://Lab/BulletHell/BulletEnemyEntity.tscn")


func _ready():
	timer.start(1.2) # explode after 1.2 sec

func _physics_process(delta):
	position += dir * speed * delta

func _onTimer_timeout():
	for i in range(0, 360, 10):
		var child_bullet = bullet_enemy.instantiate()
		var angle = deg_to_rad(i)
		child_bullet.position = position
		child_bullet.rotation = angle
		var lm = child_bullet.find_child("LinearMotionComponent")
		if lm:
			lm.initialSpeed = 100
			lm.maximumSpeed = 100
		get_parent().add_child(child_bullet)
	queue_free()
