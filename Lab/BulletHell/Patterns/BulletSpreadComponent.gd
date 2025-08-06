## Fires bullets in a spread pattern
class_name BulletSpreadComponent
extends Component

@export var bullet_count: int = 5
@export var spread_angle: float = 90.0  # Total spread in degrees
@export var fire_interval: float = 0.5  # Time between spreads
@export var auto_fire: bool = true

@onready var gun_component: GunComponent = coComponents.GunComponent

var _fire_timer := 0.0

func _ready() -> void:
	if auto_fire:
		set_process(true)
	else:
		set_process(false)

func _process(delta: float) -> void:
	_fire_timer += delta
	if _fire_timer >= fire_interval:
		_fire_timer = 0.0
		fire_spread()

func fire_spread() -> void:
	if bullet_count <= 1:
		var bullet = gun_component.fire(true)
		if bullet:
			bullet.rotation = parentEntity.rotation
		return

	var angle_step = spread_angle / float(bullet_count - 1)
	var start_angle = -spread_angle / 2.0
	var base_angle = rad_to_deg(parentEntity.rotation)
	for i in range(bullet_count):
		var bullet = gun_component.fire(true)
		if bullet:
			var bullet_angle = base_angle + start_angle + i * angle_step
			bullet.rotation = deg_to_rad(bullet_angle)
