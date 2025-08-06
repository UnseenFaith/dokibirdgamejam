class_name BounceComponent
extends AreaContactComponent

#region Parameters
@export var bounceForce: float = -400.0
#endregion

#region Dependencies
@onready var inputComponent: InputComponent = parentEntity.findFirstComponentSubclass(InputComponent)
@onready var platformerPhysicsComponent: PlatformerPhysicsComponent = coComponents.PlatformerPhysicsComponent
@onready var characterBodyComponent: CharacterBodyComponent = coComponents.CharacterBodyComponent
func getRequiredComponents() -> Array[Script]:
	return [CharacterBodyComponent, PlatformerPhysicsComponent, InputComponent]
#endregion

func _ready() -> void:
	self.shouldMonitorAreas = true
	self.shouldMonitorBodies = false
	self.shouldConnectSignalsOnReady = true
	super._ready()


#region Area collisionLayers
func onAreaEntered(areaEntered: Area2D) -> void:
	super.onAreaEntered(areaEntered)
	characterBodyComponent.body.velocity.y = bounceForce * characterBodyComponent.body.up_direction.y
	print("Area Entered")

func onAreaExited(areaExited: Area2D) -> void:
	super.onAreaExited(areaExited)
	print("Area Exited")
#endregion
