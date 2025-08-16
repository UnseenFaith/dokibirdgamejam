extends Button


func onMouseEntered() -> void:
	$"../TextureRect4".z_index = 5
	$"../AudioStreamPlayer".play()

func onMouseExited() -> void:
	$"../TextureRect4".z_index = 0
