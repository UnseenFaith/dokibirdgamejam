extends CenterContainer

signal credits()

func onCreditsButton_pressed() -> void:
	credits.emit()
