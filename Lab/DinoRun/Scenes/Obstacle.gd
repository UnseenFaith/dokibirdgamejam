## Description

class_name Crate2
extends Entity

@export var speed: float

var has_been_hit := false

# For flying effect
var fly_velocity := Vector2.ZERO
var fly_angular_velocity := 0.0

func fly_off() -> void:
	if has_been_hit:
		return
	has_been_hit = true
	fly_velocity = Vector2(randf_range(200, 500), randf_range(-700, -500))
	fly_angular_velocity = randf_range(-8, 8)

func _physics_process(delta: float) -> void:
	if not has_been_hit:
		position.x -= delta * speed
	else:
		# Gravity pulls down
		fly_velocity.y += 1000 * delta
		# "Wind" or "boomerang force" pulls left, increasing over time
		fly_velocity.x += -1200 * delta  # Increase this for a sharper curve

		position += fly_velocity * delta
		rotation += fly_angular_velocity * delta

#region Parameters
@export var isEnabled: bool = true:
	set(newValue):
		isEnabled = newValue # Don't bother checking for a change
		# PERFORMANCE: Set once instead of every frame
		self.set_process(isEnabled)
		self.set_process_input(isEnabled)
#endregion

func _ready() -> void:
	# Apply setters because Godot doesn't on initialization
	self.set_process(isEnabled)
	self.set_process_input(isEnabled)
	# Placeholder: Add any code needed to configure and prepare the component.
