extends Node

class_name AnimationComponent

@export var from_center: bool
@export var hover_scale: Vector2
@export var click_scale: Vector2
@export var time: float
@export var transition_type: Tween.TransitionType

var target: Control
var default_scale: Vector2
var active_tween: Tween
var is_hovered := false

func _ready() -> void:
	target = get_parent()
	target.mouse_filter = Control.MOUSE_FILTER_STOP
	target.connect("gui_input", Callable(self, "_on_target_gui_input"))
	connect_signals()
	call_deferred("setup")

func _on_target_gui_input(event: InputEvent) -> void:
	# 3) detect left‑click press/release
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			on_click()
		else:
			off_click()
	
func connect_signals():
	target.mouse_entered.connect(on_hover)
	target.mouse_exited.connect(off_hover)
	
func setup():
	if from_center:
		target.pivot_offset = target.size / 2
	default_scale = target.scale
	
func on_click():
	add_tween("scale", click_scale, time)

func off_click():
	if is_hovered:
		add_tween("scale", hover_scale, time)
	else:
		add_tween("scale", default_scale, time)

func on_hover():
	is_hovered = true
	add_tween("scale", hover_scale, time)
	
func off_hover():
	is_hovered = false
	add_tween("scale", default_scale, time)
	
func add_tween(property: String, value, seconds: float):
	if active_tween and active_tween.is_running():
		# if we're already tweening to this exact value, don’t restart
		if target.get(property) == value:
			return
		active_tween.kill()  # or stop() to clear the previous one
	active_tween = get_tree().create_tween()
	active_tween.tween_property(target, property, value, seconds).set_trans(transition_type)
