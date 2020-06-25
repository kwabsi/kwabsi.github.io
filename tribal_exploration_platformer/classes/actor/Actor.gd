extends KinematicBody2D
class_name Actor

var stats:ActorStats = ActorStats.new()		# All variable properties of the actor

var entryState = -1
var stateMachine:StateMachine = StateMachine.new(self)
var ragdollTimer:Timer

var velocity:Vector2 = Vector2.ZERO setget setVelocity, getVelocity

func applyForce(_force:Vector2, _forceLaunchTime:float = 0.0):
	var _velocityChange = Vector2(
		floor(_force.x / stats.physics.weight),
		floor(_force.y / stats.physics.weight))
	if _velocityChange == Vector2.ZERO:
		return
	self.velocity += _velocityChange
	if _forceLaunchTime > 0 or _velocityChange.length() > stats.physics.launchThreshold:
		launch(_forceLaunchTime)

func applyGravity(delta:float = 1.0):
	self.velocity += CONSTANTS.PHYSICS.GRAVITY * delta

func applyFriction(delta:float = 1.0):
	var _friction = self.stats.physics.friction
	if !is_on_floor():
		_friction *= self.stats.physics.airMultiplicator
	var _frictionVector = Vector2(
		-1 * sign(self.velocity.x) * abs(_friction * delta * CONSTANTS.PHYSICS.GRAVITY.normalized().y),
		-1 * sign(self.velocity.y) * abs(_friction * delta * CONSTANTS.PHYSICS.GRAVITY.normalized().x))
	var _velocity = self.velocity + _frictionVector
	if sign(_velocity.x) != sign(self.velocity.x):
		_velocity.x = 0
	if sign(_velocity.y) != sign(self.velocity.y):
		_velocity.y = 0
	self.velocity = _velocity

func performMovement(delta:float = 1.0):
	self.velocity = move_and_slide(velocity, CONSTANTS.PHYSICS.GRAVITY.normalized() * -1)
	
func launch(_forceLaunchTime:float = 0.0):
	self.stateMachine.setState(-2)
	if _forceLaunchTime > 0:
		self.ragdollTimer.start(_forceLaunchTime)
		yield(self.ragdollTimer, "timeout")
		self.stateMachine.setState(entryState)

# SETTER AND GETTER
func setVelocity(_velocity:Vector2):
	velocity = _velocity

func getVelocity() -> Vector2:
	return velocity

# INTERNAL FUNCTIONS
func _ready():
	self.ragdollTimer = Timer.new()
	add_child(self.ragdollTimer)
	set_collision_layer_bit(0, false)
	set_collision_mask_bit(0, false)
	
	set_collision_layer_bit(CONSTANTS.COLLISION.ACTOR, true)
	set_collision_mask_bit(CONSTANTS.COLLISION.SOLID, true)
	
	self.stateMachine.registerState(-1, funcref(self, "_state_fallback"))
	self.stateMachine.registerState(-2, funcref(self, "_state_ragdoll"))
	self.stateMachine.setState(entryState)

# Fallback State if something goes wrong
func _state_fallback(delta):
	applyGravity(delta)
	applyFriction(delta)
	performMovement(delta)
	
func _state_ragdoll(delta):
	applyGravity(delta)
	applyFriction(delta)
	performMovement(delta)
	if ragdollTimer.time_left == 0 and velocity.length() < stats.physics.launchThreshold:
		self.stateMachine.setState(entryState)
