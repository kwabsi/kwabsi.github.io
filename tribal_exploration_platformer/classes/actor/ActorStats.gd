extends JSONNode.Data
class_name ActorStats

enum ATTRIBUTES { HP, MP, BRAWN, BRAINS, BRAVADO }

var attributes:PropertyDictionary = PropertyDictionary.new(ATTRIBUTES)
var physics:PhysicsProperties = PhysicsProperties.new()

func fromJSON(json:Dictionary) -> JSONNode.Data:
	self.attributes.fromJSON(json.get("attributes", {}))
	self.physics.fromJSON(json.get("physics", {}))
	return self
	
func toJSON() -> Dictionary:
	var json = {}
	json["attributes"] = attributes.toJSON()
	json["physics"] = physics.toJSON()
	return json

class PhysicsProperties:
	var weight:float = 1.0				# Used for Launch-Mechanics
	var gravityMultiplier:float = 1.0
	var friction:float = 64.0
	var airMultiplicator:float = 0.2
	var launchThreshold:float = 64.0
	
	func fromJSON(json:Dictionary) -> PhysicsProperties:
		self.weight = json.get("weight", weight)
		self.gravityMultiplier = json.get("gravityMultiplier", gravityMultiplier)
		self.friction = json.get("friction", friction)
		self.airMultiplicator = json.get("airMultiplicator", airMultiplicator)
		self.launchThreshold = json.get("launchThreshold", launchThreshold)
		return self
		
	func toJSON() -> Dictionary:
		var json = {}
		json["weight"] = self.weight
		json["gravityMultiplier"] = self.gravityMultiplier
		json["friction"] = self.friction
		json["airMultiplicator"] = self.airMultiplicator
		json["launchThreshold"] = self.launchThreshold
		return json
		
class Property:
	var raw:int = 0
	var mod:int = 0
	var mult:float = 1.0
	var value:int setget setValue, getValue

	func setValue(_value:int):
		mod = raw - (_value / mult)
	
	func getValue() -> int:
		return int((raw + mod) * mult)
		
	func reset():
		mod = 0
		mult = 1.0

class PropertyDictionary:
	var dict:Dictionary = {}
	var properties:Dictionary
	
	func _init(_properties:Dictionary):
		for key in _properties.values():
			dict[key] = Property.new()
		self.properties = _properties
	
	func getValue(attributeId:int, default:int = 0) -> int:
		if not dict.has(attributeId): return default
		return dict.get(attributeId).getValue()
		
	func setValue(attributeId:int, value:int):
		if not dict.has(attributeId): return
		dict.get(attributeId).setValue(value)
	
	func resetAttribute(attributeId:int):
		if not dict.has(attributeId): return
		dict.get(attributeId).reset()

	func fromJSON(json:Dictionary) -> PropertyDictionary:
		for key in self.properties.values():
			dict.get(key).raw = json.get(key, 0)
			dict.get(key).reset()
		return self
			
	func toJSON() -> Dictionary:
		var json = {}
		for key in self.properties.values():
			json[key] = dict.get(key).raw
		return json
