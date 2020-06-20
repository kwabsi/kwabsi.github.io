extends Actor.Stats
class_name PlayerStats
	
var colors:ColorScheme = ColorScheme.new()

func _init():
	self.physics = PhysicsProperties.new()

class PhysicsProperties extends Actor.PhysicsProperties:
	var topSpeed:float = 128
	var acceleration:float = 0.5
	var deceleration:float = 0.5		# Player will NOT use friction outside of ragdoll state
	var jumpStrength:float = 160
	var jumpExtentionTime:float = 0.3
	var jumpExtentionPower:float = 0.7		# How much Gravity is ignored while the jump is being extended
	var wallrunDuration:float = 1.0
	
	func loadFromJSON(_json:Dictionary):
		.loadFromJSON(_json)
		self.topSpeed = _json.get("topSpeed", topSpeed)
		self.acceleration = _json.get("acceleration", acceleration)
		self.deceleration = _json.get("deceleration", deceleration)

class ColorScheme:
	var primaryColor:Color = Color.yellow.darkened(0.1)
	var secondaryColor:Color = Color.green.darkened(0.2)
	var teriaryColor:Color = Color.brown
	
