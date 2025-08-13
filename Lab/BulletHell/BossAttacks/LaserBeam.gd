extends Node2D

@export var laser_length: float = -700

@onready var warning_line: Line2D = $WarningLine
@onready var laser_line: Line2D = $LaserLine
@onready var damage_area: Area2D = $DamageArea

func _ready():
	_update_lines()
	warning_line.visible = false
	laser_line.visible = false
	damage_area.monitoring = false

func _update_lines():
	var end_point = Vector2(laser_length, 0)
	warning_line.points = [Vector2.ZERO, end_point]
	laser_line.points = [Vector2.ZERO, end_point]
	var shape: RectangleShape2D = damage_area.get_node("CollisionShape2D").shape
	shape.extents = Vector2(laser_length / 2, 4)
	damage_area.position = Vector2(laser_length / 2, 0)

func start_telegraph():
	warning_line.visible = true
	laser_line.visible = false
	damage_area.monitoring = false

func start_attack():
	warning_line.visible = false
	laser_line.visible = true
	damage_area.monitoring = true

func stop_attack():
	warning_line.visible = false
	laser_line.visible = false
	damage_area.monitoring = false
