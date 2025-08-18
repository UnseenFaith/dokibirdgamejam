extends Control

@export var healthComp: HealthComponent

var hp_tween: Tween

func _ready() -> void:
	$Foreground.value = healthComp.health.value
	$Foreground.max_value = healthComp.health.max
	
	healthComp.healthDidDecrease.connect(health_decreased)

func health_decreased(difference: int) -> void:
	$Foreground.value += difference
