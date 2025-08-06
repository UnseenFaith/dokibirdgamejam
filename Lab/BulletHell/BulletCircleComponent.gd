## Fires bullets in a circle pattern
class_name BulletCircleComponent
extends Component

@export var bulletCount: int = 8
@export var circleDelay: float = 0.2
@export var rotationSpeed: float = 45.0  # Degrees per second

@onready var gunComponent: GunComponent = coComponents.GunComponent

var currentAngle: float = 0.0

func _ready() -> void:
	startCirclePattern()

func _physics_process(delta: float) -> void:
	currentAngle += rotationSpeed * delta

func startCirclePattern() -> void:
	while true:
		fireCircle()
		await get_tree().create_timer(circleDelay).timeout

func fireCircle() -> void:
	var angleStep = 360.0 / bulletCount
	
	for i in range(bulletCount):
		var bullet = gunComponent.fire(true)
		if bullet:
			var bulletAngle = currentAngle + (i * angleStep)
			bullet.rotation = deg_to_rad(bulletAngle)
