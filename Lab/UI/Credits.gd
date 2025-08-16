extends Button

func onMouseEntered() -> void:
	$"../TextureRect5".z_index = 5
	$"../AudioStreamPlayer".play()

func onMouseExited() -> void:
	$"../TextureRect5".z_index = 0
