extends Control

@export var healthComp: HealthComponent


func _ready() -> void:
	$ProgressBar.max_value = healthComp.health.value
	
	healthComp.healthDidDecrease.connect(health_decreased)

func health_decreased(difference: int) -> void:
	$ProgressBar.value = $ProgressBar.value + difference
	
