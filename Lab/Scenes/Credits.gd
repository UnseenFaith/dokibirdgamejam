extends Node2D

signal cutscene_quit()

func onAnimationPlayer_animationFinished(anim_name: StringName) -> void:
	cutscene_quit.emit()
