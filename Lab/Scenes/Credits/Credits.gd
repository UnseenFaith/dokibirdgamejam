extends Control

@onready var scroll_container = $ScrollContainer

var scroll_speed := 50.0  # pixels per second
var reset_delay := 2.0    # seconds before restart after finishing
var finished := false

func _ready():
	# Start at top of scroll
	scroll_container.scroll_vertical = 0

func _process(delta):
	if finished:
		return

	scroll_container.scroll_vertical += scroll_speed * delta

	var max_scroll = scroll_container.get_v_scroll_bar().max_value
	if scroll_container.scroll_vertical >= max_scroll:
		finished = true
		await get_tree().create_timer(reset_delay).timeout
		# Optional: restart scrolling or change scene
		scroll_container.scroll_vertical = 0
		finished = false
