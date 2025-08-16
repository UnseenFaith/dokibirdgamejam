extends Button


func onMouseEntered() -> void:
	$"../TextureRect3".z_index = 5
	$AudioStreamPlayer.play()



func onMouseExited() -> void:
	$"../TextureRect3".z_index = 0
	$AudioStreamPlayer.stop()
