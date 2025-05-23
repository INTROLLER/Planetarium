extends CheckButton

var fullscreen := false

func _ready() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		fullscreen = true
		button_pressed = true
	pressed.connect(toggle)

func toggle():
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		button_pressed = false
		fullscreen = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		button_pressed = true
		fullscreen = true