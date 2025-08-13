extends Node

@onready var hearts := [$Heart, $Heart2, $Heart3, $Heart4, $Heart5]
@onready var current_heart := 4

func break_heart():
	var heart = hearts[current_heart]
	var tween = create_tween()
	tween.set_loops(2)
	tween.tween_property(heart, "modulate:a", 0.0, 0.1) # fade out
	tween.tween_property(heart, "modulate:a", 1.0, 0.1) # fade in
	tween.connect("finished", Callable(self, "_on_flash_finished"))
	
func _on_flash_finished():
	var heart = hearts[current_heart]
	heart.region_rect = $BrokenHeart.region_rect
	current_heart -= 1
	heart.modulate.a = 1.0 # make sure it's fully visible again


func onHealthComponent_healthDidDecrease(difference: int) -> void:
	break_heart()
