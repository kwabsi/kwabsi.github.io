extends ActorStats
class_name PlayerStats

var colors:ColorScheme = ColorScheme.new()

func _init():
	self.physics = PhysicsProperties.new()
	
func fromJSON(json:Dictionary):
	.fromJSON(json)
	self.physics.fromJSON(json.get("physics", {}))
	self.colors.fromJSON(json.get("colors", {}))
	return self
	
func toJSON() -> Dictionary:
	var json = .toJSON()
	json["physics"] = self.physics.toJSON()
	json["colors"] = self.colors.toJSON()
	return json

class PhysicsProperties extends ActorStats.PhysicsProperties:
	var topSpeed:float = 128
	var acceleration:float = 0.5
	var deceleration:float = 0.5		# Player will NOT use friction outside of ragdoll state
	var jumpStrength:float = 160
	var jumpExtentionTime:float = 0.3
	var jumpExtentionPower:float = 0.7		# How much Gravity is ignored while the jump is being extended
	var wallrunDuration:float = 1.0
	
	func fromJSON(json:Dictionary):
		.fromJSON(json)
		self.topSpeed = json.get("topSpeed", topSpeed)
		self.acceleration = json.get("acceleration", acceleration)
		self.deceleration = json.get("deceleration", deceleration)
		self.jumpStrength = json.get("jumpStrength", jumpStrength)
		self.jumpExtentionTime = json.get("jumpExtentionTime", jumpExtentionTime)
		self.jumpExtentionPower = json.get("jumpExtentionPower", jumpExtentionPower)
		self.wallrunDuration = json.get("wallrunDuration", wallrunDuration)
		return self
		
	func toJSON() -> Dictionary:
		var json = .toJSON()
		json["topSpeed"] = self.topSpeed
		json["acceleration"] = self.acceleration
		json["deceleration"] = self.deceleration
		json["jumpStrength"] = self.jumpStrength
		json["jumpExtentionTime"] = self.jumpExtentionTime
		json["jumpExtentionPower"] = self.jumpExtentionPower
		json["wallrunDuration"] = self.wallrunDuration
		return json
	
class ColorScheme:
	var primaryColor:Color = Color.yellow.darkened(0.1)
	var secondaryColor:Color = Color.green.darkened(0.2)
	var teriaryColor:Color = Color.brown
	var skinColor:Color = Color.burlywood
	var hairColor:Color = Color.brown
	var eyeColor:Color = Color.blue
	
	func fromJSON(json:Dictionary) -> ColorScheme:
		self.primaryColor = Color(json.get("primaryColor", "ffffff"))
		self.secondaryColor = Color(json.get("secondaryColor", "ffffff"))
		self.teriaryColor = Color(json.get("teriaryColor", "ffffff"))
		self.skinColor = Color(json.get("skinColor", "ffffff"))
		self.hairColor = Color(json.get("hairColor", "ffffff"))
		self.eyeColor = Color(json.get("eyeColor", "ffffff"))
		return self
	
	func toJSON() -> Dictionary:
		var json = {}
		json["primaryColor"] = self.primaryColor.to_html()
		json["secondaryColor"] = self.secondaryColor.to_html()
		json["teriaryColor"] = self.teriaryColor.to_html()
		json["skinColor"] = self.skinColor.to_html()
		json["hairColor"] = self.hairColor.to_html()
		json["eyeColor"] = self.eyeColor.to_html()
		return json
