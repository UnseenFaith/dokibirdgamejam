## Emits dust particles behind the character when running.
## The particles are spawned behind the character based on movement direction.
## Requirements: [InputComponent]

class_name DustParticleComponent
extends Component


#region Parameters

## The particle system to use for dust effects
@export var dustParticleScene: PackedScene

## How far behind the character to spawn particles (in pixels)
@export_range(0, 50, 1) var spawnDistanceBehind: float = 8

## Minimum horizontal movement speed to trigger dust particles
@export_range(0, 1, 0.1) var minMovementThreshold: float = 0.1

## How often to spawn particles when running (in seconds)
@export_range(0.01, 0.5, 0.01) var spawnInterval: float = 0.1

## Maximum number of dust particles to keep alive at once
@export_range(1, 20, 1) var maxParticles: int = 5

## Should the dust particles be affected by gravity?
@export var shouldUseGravity: bool = true

## The lifetime of each dust particle (in seconds)
@export_range(0.1, 3.0, 0.1) var particleLifetime: float = 1.0

## The initial velocity of dust particles
@export var particleVelocity: Vector2 = Vector2(0, -20)

@export var isEnabled: bool = true

#endregion


#region State
var spawnTimer: float = 0.0
var activeParticles: Array[Node2D] = []
var isMoving: bool = false
#endregion


#region Signals
signal didSpawnDustParticle(particle: Node2D, spawnPosition: Vector2)
#endregion


#region Dependencies
@onready var inputComponent: InputComponent = parentEntity.findFirstComponentSubclass(InputComponent)

## Returns a list of required component types that this component depends on.
func getRequiredComponents() -> Array[Script]:
	return [InputComponent]
#endregion


func _ready() -> void:
	if not dustParticleScene:
		# Create a default dust particle if none is provided
		dustParticleScene = createDefaultDustParticle()
	
	if debugMode:
		printDebug("DustParticleComponent initialized")


func _process(delta: float) -> void:
	if not isEnabled or not inputComponent: return
	
	# Check if character is moving
	var movementMagnitude: float = inputComponent.movementDirection.length()
	isMoving = movementMagnitude > minMovementThreshold
	
	if isMoving:
		spawnTimer += delta
		if spawnTimer >= spawnInterval:
			spawnTimer = 0.0
			spawnDustParticle()
	
	# Clean up old particles
	cleanupParticles()


## Spawn a dust particle behind the character
func spawnDustParticle() -> void:
	if not dustParticleScene: return
	
	# Calculate spawn position behind the character
	var spawnPosition: Vector2 = calculateSpawnPosition()
	
	# Create the particle
	var particle: Node2D = dustParticleScene.instantiate() as Node2D
	if not particle:
		printError("Failed to instantiate dust particle scene")
		return
	
	# Add to scene
	get_tree().current_scene.add_child(particle)
	particle.global_position = spawnPosition
	
	# Set up particle properties
	setupParticle(particle)
	
	# Track the particle
	activeParticles.append(particle)
	
	if debugMode:
		printDebug("Spawned dust particle at: " + str(spawnPosition))
	
	didSpawnDustParticle.emit(particle, spawnPosition)


## Calculate where to spawn the dust particle (behind the character)
func calculateSpawnPosition() -> Vector2:
	var characterPosition: Vector2 = parentEntity.global_position
	var movementDirection: Vector2 = inputComponent.movementDirection.normalized()
	
	# Spawn behind the character (opposite to movement direction)
	var spawnOffset: Vector2 = -movementDirection * spawnDistanceBehind
	
	return characterPosition + spawnOffset


## Set up particle properties
func setupParticle(particle: Node2D) -> void:
	# If it's a GPUParticles2D, configure it
	if particle is GPUParticles2D:
		var gpuParticle: GPUParticles2D = particle as GPUParticles2D
		gpuParticle.emitting = true
		gpuParticle.lifetime = particleLifetime
		#gpuParticle.gravity = Vector2.ZERO if not shouldUseGravity else Vector2(0, 98)
		#gpuParticle.initial_velocity_min = particleVelocity * 0.8
		#gpuParticle.initial_velocity_max = particleVelocity * 1.2
	
	# If it's a regular Node2D with a timer, set up the timer
	elif particle.has_method("setLifetime"):
		particle.setLifetime(particleLifetime)
	
	# Set a timer to remove the particle
	var timer: Timer = Timer.new()
	particle.add_child(timer)
	timer.wait_time = particleLifetime
	timer.one_shot = true
	timer.timeout.connect(func(): removeParticle(particle))
	timer.start()


## Remove a specific particle
func removeParticle(particle: Node2D) -> void:
	if particle in activeParticles:
		activeParticles.erase(particle)
	
	if is_instance_valid(particle):
		particle.queue_free()


## Clean up old particles
func cleanupParticles() -> void:
	for i in range(activeParticles.size() - 1, -1, -1):
		var particle: Node2D = activeParticles[i]
		if not is_instance_valid(particle):
			activeParticles.remove_at(i)


## Create a default dust particle scene if none is provided
func createDefaultDustParticle() -> PackedScene:
	# Create a simple dust particle using GPUParticles2D
	var particleNode: GPUParticles2D = GPUParticles2D.new()
	
	# Create a simple circle shape for the particle
	var circleShape: CircleShape2D = CircleShape2D.new()
	circleShape.radius = 2
	
	# Configure the particle system
	particleNode.amount = 1
	particleNode.lifetime = particleLifetime
	particleNode.one_shot = true
	particleNode.explosiveness = 0.0
	particleNode.randomness = 0.5
	particleNode.visibility_rect = Rect2(-10, -10, 20, 20)
	
	# Set up the particle material
	var particleMaterial: ParticleProcessMaterial = ParticleProcessMaterial.new()
	particleMaterial.gravity = Vector3.ZERO if not shouldUseGravity else Vector3(0, 98, 0)
	particleMaterial.initial_velocity_min = particleVelocity.length() * 0.8
	particleMaterial.initial_velocity_max = particleVelocity.length() * 1.2
	particleMaterial.scale_min = 0.5
	particleMaterial.scale_max = 1.5
	particleMaterial.color = Color(0.7, 0.6, 0.4, 0.8)  # Dusty brown color
	particleMaterial.color_ramp = createDustGradient()
	
	particleNode.process_material = particleMaterial
	
	# Create a scene from the node
	var scene: PackedScene = PackedScene.new()
	scene.pack(particleNode)
	
	return scene


## Create a gradient for the dust particle color
func createDustGradient() -> GradientTexture1D:
	var gradient: Gradient = Gradient.new()
	gradient.colors = [
		Color(0.7, 0.6, 0.4, 0.8),  # Start: dusty brown
		Color(0.7, 0.6, 0.4, 0.4),  # Middle: semi-transparent
		Color(0.7, 0.6, 0.4, 0.0)   # End: fully transparent
	]
	
	var gradientTexture: GradientTexture1D = GradientTexture1D.new()
	gradientTexture.gradient = gradient
	
	return gradientTexture


## Force spawn a dust particle (useful for testing or manual triggering)
func forceSpawnDustParticle() -> void:
	spawnDustParticle()


## Clear all active particles
func clearAllParticles() -> void:
	for particle in activeParticles:
		if is_instance_valid(particle):
			particle.queue_free()
	activeParticles.clear()
