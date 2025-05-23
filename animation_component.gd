extends Node  # This script extends Node to provide mouse-driven scale animations for Control nodes

# Register this class as “AnimationComponent” for use in the editor
class_name AnimationComponent

# Exported properties to customize animation behavior in the Inspector
@export var from_center: bool               # If true, pivot offset will be set to the center of the target
@export var hover_scale: Vector2            # Scale to apply when the mouse hovers over the target
@export var click_scale: Vector2            # Scale to apply when the target is clicked
@export var time: float                     # Duration (in seconds) of all tweens
@export var transition_type: Tween.TransitionType  # Tween transition type (e.g., linear, back, etc.)

# Internal variables used at runtime
var target: Control         # The Control node this component animates (parent of this script)
var default_scale: Vector2  # The original scale of the target, stored on setup
var active_tween: Tween     # Reference to the currently running tween (if any)
var is_hovered := false     # Tracks whether the mouse is currently over the target

func _ready() -> void:
    # Called when this Node enters the scene tree
    target = get_parent()
    # Assume this script is a child of a Control node; store that node as the target

    target.mouse_filter = Control.MOUSE_FILTER_STOP
    # Prevent clicks/hover events from passing through the target to nodes behind it

    target.connect("gui_input", Callable(self, "_on_target_gui_input"))
    # Connect the target’s gui_input signal to our custom handler for clicks

    connect_signals()
    # Connect the target’s mouse_entered and mouse_exited signals to hover handlers

    call_deferred("setup")
    # Defer setup until the next idle frame, so the target’s size is guaranteed initialized

func _on_target_gui_input(event: InputEvent) -> void:
    # Handle low-level GUI input events on the target
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        # Only respond to left-click button events
        if event.pressed:
            on_click()
            # If the mouse button was just pressed, play the click animation
        else:
            off_click()
            # If the mouse button was released, revert to hover or default state

func connect_signals():
    # Connect hover enter/exit signals on the target to scale animations
    target.mouse_entered.connect(on_hover)
    target.mouse_exited.connect(off_hover)

func setup():
    # Called once, deferred, to finalize initial configuration
    if from_center:
        target.pivot_offset = target.size / 2
        # If “from_center” is true, adjust the pivot so scaling originates from center

    default_scale = target.scale
    # Cache the target’s initial scale for use when returning to the default state

func on_click():
    # Play the “click” scale animation when the target is pressed
    add_tween("scale", click_scale, time)

func off_click():
    # When the mouse button is released, choose the appropriate scale
    if is_hovered:
        add_tween("scale", hover_scale, time)
        # If still hovered, return to hover scale
    else:
        add_tween("scale", default_scale, time)
        # Otherwise, return to the original default scale

func on_hover():
    # Called when the mouse first enters the target’s area
    is_hovered = true
    add_tween("scale", hover_scale, time)
    # Animate to the hover scale

func off_hover():
    # Called when the mouse exits the target’s area
    is_hovered = false
    add_tween("scale", default_scale, time)
    # Animate back to the default scale

func add_tween(property: String, value, seconds: float):
    # Helper function to start or restart a tween on the target’s property
    if active_tween and active_tween.is_running():
        # If there is an active tween running:
        if target.get(property) == value:
            return
            # If the property is already animating toward the same value, skip restarting

        active_tween.kill()
        # Otherwise, kill the existing tween so we can start a new one

    active_tween = get_tree().create_tween()
    # Create a new Tween on the SceneTree

    active_tween.tween_property(target, property, value, seconds).set_trans(transition_type)
    # Animate the specified property (e.g., "scale") on the target to the given value over duration,
    # using the exported transition type for easing