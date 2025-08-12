## Creates chaotic and unpredictable bullet patterns
## Updated to work with PathFollowComponent and prevent offscreen spawning
class_name WeirdBulletPatternComponent
extends Component

@export var patternTypes: Array[String] = ["chaos", "zigzag", "spiral", "random", "wave"]
@export var patternChangeInterval: float = 2.0
@export var bulletSpeed: float = 200.0
@export var chaosLevel: float = 1.0  # 0.0 = normal, 1.0 = maximum chaos
@export var maxBulletsPerBurst: int = 15
@export var shouldAimAtPlayer: bool = true  # Try to aim bullets toward player
@export var screenBoundsMargin: float = 50.0  # Keep bullets within screen bounds

@onready var gunComponent: GunComponent = coComponents.GunComponent
@onready var pathFollowComponent: PathFollowComponent = coComponents.get("PathFollowComponent")

var currentPattern: String = "chaos"
var time: float = 0.0
var patternTime: float = 0.0
var lastPatternChange: float = 0.0
var randomSeed: int = 0
var playerPosition: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomSeed = randi()
	startWeirdPattern()

func _physics_process(delta: float) -> void:
	time += delta
	patternTime += delta
	
	# Update player position for aiming
	updatePlayerPosition()
	
	# Change pattern periodically
	if time - lastPatternChange > patternChangeInterval:
		changePattern()
		lastPatternChange = time
		patternTime = 0.0

func updatePlayerPosition() -> void:
	# Try to find the player for aiming
	var player = get_tree().get_first_node_in_group("player")
	if player:
		playerPosition = player.global_position
	else:
		# If no player found, use screen center as fallback
		var viewport = get_viewport()
		if viewport:
			playerPosition = viewport.get_visible_rect().get_center()

func startWeirdPattern() -> void:
	while true:
		# Only fire if the boss is on screen or near screen
		if isBossOnScreen():
			match currentPattern:
				"chaos":
					fireChaosPattern()
				"zigzag":
					fireZigzagPattern()
				"spiral":
					fireSpiralPattern()
				"random":
					fireRandomPattern()
				"wave":
					fireWavePattern()
		
		await get_tree().create_timer(0.05).timeout

func isBossOnScreen() -> bool:
	var viewport = get_viewport()
	if not viewport:
		return true  # Default to true if we can't check
	
	var screenRect = viewport.get_visible_rect()
	var bossPos = parentEntity.global_position
	
	# Check if boss is within screen bounds with margin
	return screenRect.has_point(bossPos) or \
		   screenRect.grow(screenBoundsMargin).has_point(bossPos)

func changePattern() -> void:
	var newPattern = patternTypes[randi() % patternTypes.size()]
	if newPattern != currentPattern:
		currentPattern = newPattern
		print("Changed to pattern: ", currentPattern)

func fireChaosPattern() -> void:
	var bulletCount = randi_range(3, maxBulletsPerBurst)
	
	for i in range(bulletCount):
		var bullet = gunComponent.fire(true)
		if bullet:
			# Aim toward player with chaos
			var aimAngle = getAimAngle()
			var chaosOffset = (randf() - 0.5) * 180.0 * chaosLevel
			var finalAngle = aimAngle + chaosOffset
			
			bullet.rotation = deg_to_rad(finalAngle)
			
			# Add some random speed variation
			var linearMotion = bullet.components.get("LinearMotionComponent")
			if linearMotion:
				linearMotion.initialSpeed = bulletSpeed + randf_range(-50, 50)

func fireZigzagPattern() -> void:
	var zigzagCount = 8
	var zigzagAngle = 45.0
	var baseAngle = getAimAngle()
	
	for i in range(zigzagCount):
		var bullet = gunComponent.fire(true)
		if bullet:
			var angle = baseAngle + (i * zigzagAngle) + (sin(time * 3.0) * 30.0)
			bullet.rotation = deg_to_rad(angle)

func fireSpiralPattern() -> void:
	var spiralArms = 6
	var spiralAngle = time * 90.0  # Rotating spiral
	var baseAngle = getAimAngle()
	
	for i in range(spiralArms):
		var bullet = gunComponent.fire(true)
		if bullet:
			var angle = baseAngle + spiralAngle + (i * 360.0 / spiralArms)
			bullet.rotation = deg_to_rad(angle)

func fireRandomPattern() -> void:
	var bulletCount = randi_range(5, 12)
	var centerAngle = getAimAngle()
	var spreadAngle = randf_range(30.0, 120.0)
	
	for i in range(bulletCount):
		var bullet = gunComponent.fire(true)
		if bullet:
			var angle = centerAngle + (randf() - 0.5) * spreadAngle
			bullet.rotation = deg_to_rad(angle)

func fireWavePattern() -> void:
	var waveCount = 10
	var waveAmplitude = 60.0
	var waveFrequency = 2.0
	var baseAngle = getAimAngle()
	
	for i in range(waveCount):
		var bullet = gunComponent.fire(true)
		if bullet:
			var angle = baseAngle + (i * 360.0 / waveCount)
			var waveOffset = sin(time * waveFrequency + i * 0.5) * waveAmplitude
			var finalAngle = angle + waveOffset
			bullet.rotation = deg_to_rad(finalAngle)

func getAimAngle() -> float:
	if shouldAimAtPlayer and playerPosition != Vector2.ZERO:
		# Calculate angle from boss to player
		var direction = (playerPosition - parentEntity.global_position).normalized()
		return rad_to_deg(atan2(direction.y, direction.x))
	else:
		# If no player or aiming disabled, use boss's current rotation
		return rad_to_deg(parentEntity.rotation)

func getRequiredComponents() -> Array[Script]:
	return [GunComponent]
