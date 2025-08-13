extends Node2D

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

func _physics_process(delta: float) -> void:
	position.x -= delta * 100


func onLaser_bodyEntered(body: Node2D) -> void:
	if body is Entity:
		var drc = body.getComponent(HealthComponent) as HealthComponent
		if drc:
			drc.damage(1)
