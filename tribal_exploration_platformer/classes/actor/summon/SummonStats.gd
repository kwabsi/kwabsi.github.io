extends ActorStats
class_name SummonStats

func _init():
	self.physics = PhysicsProperties.new()
	pass

class PhysicsProperties extends ActorStats.PhysicsProperties:
	var topSpeed:float = 128
	var acceleration:float = 0.5
	var jumpStrength:float = 160
