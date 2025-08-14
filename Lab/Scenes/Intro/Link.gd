extends Label

@export var message := "Hello, test message!"
@export var typing_speed := 0.05
@export var gibberish_time := 1.5
@export var gibberish_length := 12
@export var morph_speed := 0.03

signal morph_done()


var _current_index := 0
var _typing_done := false
var _timer := 0.0
var _morphing := false
var _target_text := ""
var _current_chars := []

func _ready() -> void:
	text = ""
	add_theme_color_override("font_color", Color(0, 0, 0))

func _process(delta: float) -> void:
	_timer += delta

	if not _typing_done:
		_timer += delta
		if _timer >= typing_speed:
			_timer = 0.0
			if _current_index < message.length():
				_current_index += 1
				text = message.substr(0, _current_index)
			else:
				_typing_done = true
				_timer = 0.0
	elif not _morphing:
		if _timer >= gibberish_time:
			_morphing = true
			_timer = 0.0
			_target_text = make_gibberish_link(gibberish_length)
			_current_chars = text.split("")
			# Pad to target length
			while _current_chars.size() < _target_text.length():
				_current_chars.append(" ")
	else:
		if _timer >= morph_speed:
			_timer = 0.0
			morph_step()

func morph_step() -> void:
	var changed := false
	for i in range(_current_chars.size()):
		if i < _target_text.length() and _current_chars[i] != _target_text[i]:
			# Randomly change a character towards target
			if randi() % 4 == 0: # 25% chance per frame
				_current_chars[i] = random_char() if _current_chars[i] != _target_text[i] else _target_text[i]
				changed = true
			else:
				_current_chars[i] = _target_text[i] if randi() % 6 == 0 else _current_chars[i]
				changed = true
	text = "".join(_current_chars)

	# When fully morphed, style it like a link
	if "".join(_current_chars) == _target_text:
		add_theme_color_override("font_color", Color(0, 0, 1))
		var style := StyleBoxFlat.new()
		style.border_color = Color(0, 0, 1)
		style.bg_color = Color(0, 0, 0, 0)
		style.border_width_bottom = 1
		set("theme_override_styles/normal", style)
		morph_done.emit()
		set_process(false)

func make_gibberish_link(length: int) -> String:
	var chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var gib := ""
	for i in range(length):
		gib += chars[randi() % chars.length()]
	return "https://" + gib.to_lower() + ".com"
	
func random_char() -> String:
	var chars := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
	return chars[randi() % chars.length()]


func onVisibilityChanged() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
