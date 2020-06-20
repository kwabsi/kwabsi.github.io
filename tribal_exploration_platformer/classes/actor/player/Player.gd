extends Actor
class_name Player

signal direction_changed(newDirection)

enum STATE { MOVEMENT, WALL_RUN }

enum BUFFER { ON_GROUND, JUMP_EXTENTION, WALLRUN_EXIT, WALLRUN_DIRECTION_CANCEL }
const PHYSICS_BUFFER_LENGTH = 0.2
var buffer:Buffer = Buffer.new(self, PHYSICS_BUFFER_LENGTH)

enum ANIMATION { IDLE, IN_AIR, RUNNING, WALL_RUNNING }
var animationDict:Dictionary = {
	ANIMATION.IDLE: "idle",
	ANIMATION.IN_AIR: "in_air",
	ANIMATION.RUNNING: "run",
	ANIMATION.WALL_RUNNING: "wall_run",
}

enum DIRECTION { LEFT, RIGHT }
var direction setget setDirection

func _init():
	self.entryState = STATE.MOVEMENT
	self.stats = PlayerStats.new()

func _ready():
	self.stateMachine.registerState(STATE.MOVEMENT, funcref(self, "_state_movement_process"))
	self.stateMachine.registerState(STATE.WALL_RUN, funcref(self, "_state_wallrun_process"), funcref(self, "_state_wallrun_enter"))

func jump(_refreshJumpExtention:bool = true):
	self.velocity.y = -1 * self.stats.physics.jumpStrength
	self.buffer.consume(BUFFER.ON_GROUND)
	if _refreshJumpExtention:
		self.buffer.insert(BUFFER.JUMP_EXTENTION, self.stats.physics.jumpExtentionTime)
		
func wallJump(_refreshJumpExtention:bool = true):
	jump(_refreshJumpExtention)
	var _dir = 1
	if self.direction == DIRECTION.LEFT:
		_dir *= -1
	self.velocity.x = -1 * _dir * self.stats.physics.topSpeed
	if self.direction == DIRECTION.LEFT: self.setDirection(DIRECTION.RIGHT)
	else: self.setDirection(DIRECTION.LEFT)
	self.buffer.consume(BUFFER.WALLRUN_DIRECTION_CANCEL)
	self.buffer.consume(BUFFER.WALLRUN_EXIT)
	self.buffer.insert(BUFFER.WALLRUN_EXIT, 0.1)

func applyGravity(delta:float = 1.0):
	if is_on_floor():
		self.velocity.y = 8.0
	else:
		self.velocity += CONSTANTS.PHYSICS.GRAVITY * delta

func handleHorizontalMovement(_inputVector:Vector2, delta:float):
	var _newVelocity = self.velocity
	var _topSpeed = self.stats.physics.topSpeed
	var _acceleration = self.stats.physics.acceleration
	var _deceleration = self.stats.physics.deceleration
	if !is_on_floor():
		_acceleration /= self.stats.physics.airMultiplicator
		_deceleration /= self.stats.physics.airMultiplicator 
	if _newVelocity.x == 0 or sign(_inputVector.x) != sign(_newVelocity.x):
		_newVelocity.x -= sign(_newVelocity.x) * _topSpeed * (delta / _deceleration)
		if sign(_newVelocity.x) != sign(velocity.x):
			_newVelocity.x = 0
	if _inputVector.x != 0:
		if abs(_newVelocity.x) < _topSpeed:
			_newVelocity.x += _inputVector.x * _topSpeed * (delta / _acceleration)
			_newVelocity.x = sign(_newVelocity.x) * min(abs(_newVelocity.x), _topSpeed)
	self.velocity = _newVelocity

func _state_movement_process(delta:float):
	var _inputVector = InputExt.getInputVector()
	handleHorizontalMovement(_inputVector, delta)
	applyGravity(delta)
	# Jumping
	if is_on_floor() or self.buffer.check(BUFFER.ON_GROUND):
		if InputExt.is_action_just_pressed("act_jump"):
			jump()
	else:
		if (InputExt.is_action_just_pressed("act_jump")
		and (not self.buffer.check(BUFFER.WALLRUN_EXIT) or self.buffer.check(BUFFER.WALLRUN_DIRECTION_CANCEL))
		and (self.buffer.check(BUFFER.WALLRUN_DIRECTION_CANCEL) or $WallChecker.touchesWall())):
			wallJump()
		if self.buffer.check(BUFFER.JUMP_EXTENTION) and Input.is_action_pressed("act_jump"):
			velocity.y -= CONSTANTS.PHYSICS.GRAVITY.y * self.stats.physics.gravityMultiplier * delta * self.stats.physics.jumpExtentionPower
		else:
			self.buffer.consume(BUFFER.JUMP_EXTENTION)
	# Animation Handling
	if is_on_floor():
		if _inputVector.x != 0:
			$AnimationPlayer.play(animationDict[ANIMATION.RUNNING])
			if _inputVector.x > 0:
				self.direction = DIRECTION.RIGHT
			else:
				self.direction = DIRECTION.LEFT
		else:
			$AnimationPlayer.play(animationDict[ANIMATION.IDLE])
	else:
		$AnimationPlayer.play(animationDict[ANIMATION.IN_AIR])
		$AnimationPlayer.seek(0.5 + (sign(velocity.y) * min(1.0, abs(velocity.y) / self.stats.physics.topSpeed) / 2))
	var _wasOnFloor = is_on_floor()
	performMovement(delta)
	# State Changes
	if is_on_floor():
		pass
	else:
		if (_inputVector.x != 0 and !self.buffer.check(BUFFER.WALLRUN_EXIT) and $WallChecker.touchesWall() and
		(not Input.is_action_pressed("act_jump") or self.velocity.y >= 0) and
		((direction == DIRECTION.LEFT and _inputVector.x < 0) or (direction == DIRECTION.RIGHT and _inputVector.x > 0))):
			self.stateMachine.setState(STATE.WALL_RUN)
			return
	# Refresh Ground Buffer
	if _wasOnFloor != is_on_floor():
		if _wasOnFloor:
			self.buffer.insert(BUFFER.ON_GROUND)
		if is_on_floor() or velocity.y < 0:
			self.buffer.consume(BUFFER.ON_GROUND)
			self.buffer.consume(BUFFER.WALLRUN_EXIT)

func _state_wallrun_enter(__):
	Input.action_release("act_jump")
	$AnimationPlayer.play(animationDict[ANIMATION.WALL_RUNNING])
	var _dir = 1
	if direction == DIRECTION.LEFT:
		_dir *= -1
	self.velocity = Vector2(
		_dir * 64,
		-1 * self.stats.physics.topSpeed)
	
func _state_wallrun_process(delta):
	self.velocity.y += self.stats.physics.topSpeed * delta / self.stats.physics.wallrunDuration
	self.velocity = move_and_slide(self.velocity)
	if self.velocity.y >= 0 or !$WallChecker.touchesWall():
		self.velocity.x = 0
		jump()
		self.stateMachine.setState(STATE.MOVEMENT)
		self.buffer.insert(BUFFER.WALLRUN_EXIT, 2.0)
		return
	if Input.is_action_just_pressed("act_jump"):
		wallJump()
		self.stateMachine.setState(STATE.MOVEMENT)
		return
	var _inputDir = InputExt.getInputVector()
	if (self.direction == DIRECTION.LEFT and _inputDir.x >= 0 or self.direction == DIRECTION.RIGHT and _inputDir.x <= 0):
		self.velocity = Vector2.ZERO
		self.buffer.insert(BUFFER.WALLRUN_DIRECTION_CANCEL)
		self.stateMachine.setState(STATE.MOVEMENT)
		self.buffer.insert(BUFFER.WALLRUN_EXIT, 2.0)
		return

# SETTER
func setDirection(_direction):
	if _direction != self.direction:
		direction = _direction
		emit_signal("direction_changed", direction)

