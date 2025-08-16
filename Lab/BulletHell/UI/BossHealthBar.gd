extends Control

@export var healthComp: HealthComponent

var hp_tween: Tween

func _ready() -> void:
	#$Background.value = healthComp.health.value
	#$Background.max_value = healthComp.health.value
	#$Foreground.value = healthComp.health.value
	#$Foreground.max_value = healthComp.health.value
	
	healthComp.healthDidDecrease.connect(health_decreased)

func health_decreased(difference: int) -> void:
	pass
	#$Foreground.value += difference
	
	#if hp_tween and hp_tween.is_running():
	#	hp_tween.kill()
	
	#hp_tween = create_tween()
	#hp_tween.tween_property($Background, "value", $Background.value + difference, 0.6) \
	#	.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
