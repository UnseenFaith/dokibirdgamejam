## Fires bullets in a spiral pattern
class_name BulletSpiralComponent
extends Component

@export var spiralArms: int = 3
@export var bulletsPerArm: int = 5
@export var spiralDelay: float = 0.1
@export var spiralSpeed: float = 30.0

@onready var gunComponent: GunComponent = coComponents.GunComponent

var currentAngle: float = 0.0

func _ready() -> void:
	startSpiralPattern()

func _physics_process(delta: float) -> void:
	currentAngle += spiralSpeed * delta

func startSpiralPattern() -> void:
	while true:
		fireSpiral()
		await get_tree().create_timer(spiralDelay).timeout

func fireSpiral() -> void:
	var angleStep = 360.0 / spiralArms
	
	for arm in range(spiralArms):
		var bullet = gunComponent.fire(true)
		if bullet:
			var bulletAngle = currentAngle + (arm * angleStep)
			bullet.rotation = deg_to_rad(bulletAngle)
