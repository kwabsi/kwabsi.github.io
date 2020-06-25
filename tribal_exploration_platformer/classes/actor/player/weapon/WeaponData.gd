tool
extends JSONNode
class_name Weapon

export var displayName:String setget setDisplayName, getDisplayName
export var texture:Texture setget setTexture, getTexture
export var projectile:int setget setProjectile, getProjectile
export var damage:int setget setDamage, getDamage
export var fireRate:float setget setFireRate, getFireRate
export var ammunition:int setget setAmmunition, getAmmunition
export var kickback:int setget setKickback, getKickback
export var accuracy:int setget setAccuracy, getAccuracy
export var weight:int setget setWeight, getWeight
export var twoHanded:bool setget setTwoHanded, getTwoHanded

export var originPosition:Vector2 setget setOriginPosition, getOriginPosition
export var muzzlePosition:Vector2 setget setMuzzlePosition, getMuzzlePosition

export var primaryColor:Color setget setPrimaryColor, getPrimaryColor
export var secondaryColor:Color setget setSecondaryColor, getSecondaryColor
export var projectileColor:Color setget setProjectileColor, getProjectileColor

func _init():
	self.data = Data.new()

func setDisplayName(value):
	self.data.displayName = value
	
func getDisplayName() -> String:
	return self.data.displayName

func setTexture(value:Texture):
	self.data.texture = value.resource_path
	
func getTexture():
	return load(self.data.texture)
	
func setDamage(value):
	self.data.damage = value
	
func getDamage() -> int:
	return self.data.damage
	
func setProjectile(value):
	self.data.projectile = value
	
func getProjectile() -> int:
	return self.data.projectile
	
func setFireRate(value):
	self.data.fireRate = value
	
func getFireRate() -> float:
	return self.data.fireRate

func setAmmunition(value):
	self.data.ammunition = value
	
func getAmmunition() -> int:
	return self.data.ammunition

func setKickback(value):
	self.data.kickback = value
	
func getKickback() -> int:
	return self.data.kickback
	
func setAccuracy(value):
	self.data.accuracy = value
	
func getAccuracy() -> int:
	return self.data.accuracy
	
func setWeight(value):
	self.data.weight = value
	
func getWeight() -> int:
	return self.data.weight
	
func setTwoHanded(value):
	self.data.twoHanded = value
	
func getTwoHanded() -> bool:
	return self.data.twoHanded

func setMuzzlePosition(value):
	self.data.muzzle = value
	
func getMuzzlePosition() -> Vector2:
	return self.data.muzzle

func setOriginPosition(value):
	self.data.origin = value
	
func getOriginPosition() -> Vector2:
	return self.data.origin

func setPrimaryColor(value):
	self.data.primaryColor = value
	
func getPrimaryColor() -> Color:
	return self.data.primaryColor
	
func setSecondaryColor(value):
	self.data.secondaryColor = value
	
func getSecondaryColor() -> Color:
	return self.data.secondaryColor
	
func setProjectileColor(value):
	self.data.projectileColor = value
	
func getProjectileColor() -> Color:
	return self.data.projectileColor

class Data extends JSONNode.Data:
	const BASE_DEGREES_PER_SECOND = 90
	
	var displayName:String
	var texture:String
	var projectile:int
	var ammunition:int
	var damage:int
	var fireRate:float		# Seconds per Shot
	var kickback:int		# Amount of aim variance added after shot
	var accuracy:int		# Inverse Percentage of the maximum aim variance.
							# Values under 50 don't resolve to 0 Variance
	var weight:int			# Abstraction; Influences how fast you can aim the weapon,
							# how much kickback is added to arm rotation after shot
							# and how much capacity this weapon requires in inventory
							# Value from 0 (Handgun) to 10 (Minigun-Like)
	var twoHanded:bool		# Halves Weight and Kickback
	
	var origin:Vector2
	var muzzle:Vector2
	
	var primaryColor:Color
	var secondaryColor:Color
	var projectileColor:Color
	
	func fromJSON(json:Dictionary):
		self.displayName = json.get("displayName", "Gun")
		self.texture = json.get("texture", "")
		self.projectile = json.get("projectile", 0)
		self.ammunition = json.get("ammunition", 0)
		self.damage = json.get("damage", 0)
		self.fireRate = json.get("fireRate", 0.0)
		self.kickback = json.get("kickback", 0)
		self.accuracy = json.get("accuracy", 0)
		self.weight = json.get("weight", 0)
		self.twoHanded = json.get("twoHanded", false)
		self.origin = Vector2(json.get("origin", { "x": 0 }).get("x", 0), json.get("origin", { "y": 0 }).get("y", 0))
		self.muzzle = Vector2(json.get("muzzle", { "x": 0 }).get("x", 0), json.get("muzzle", { "y": 0 }).get("y", 0))
		self.primaryColor = Color(json.get("primaryColor", "ffffff"))
		self.secondaryColor = Color(json.get("secondaryColor", "ffffff"))
		self.projectileColor = Color(json.get("projectileColor", "ffffff"))
		return self
	
	func toJSON() -> Dictionary:
		var json = .toJSON()
		json["displayName"] = self.displayName
		json["texture"] = self.texture
		json["projectile"] = self.projectile
		json["ammunition"] = self.ammunition
		json["damage"] = self.damage
		json["fireRate"] = self.fireRate
		json["kickback"] = self.kickback
		json["accuracy"] = self.accuracy
		json["weight"] = self.weight
		json["twoHanded"] = self.twoHanded
		json["origin"] = { "x": self.origin.x, "y": self.origin.y }
		json["muzzle"] = { "x": self.muzzle.x, "y": self.muzzle.y }
		json["primaryColor"] = self.primaryColor.to_html()
		json["secondaryColor"] = self.secondaryColor.to_html()
		json["projectileColor"] = self.projectileColor.to_html()
		return json
	
	func getBrawnsFactor(playerStats:PlayerStats) -> float:
		var brawn = playerStats.attributes.getValue(ActorStats.ATTRIBUTES.BRAWN)
		return pow(max(float(10 - brawn), 0.5) / 10.0, 1.2) * 2
		
	func getMaxVariance(playerStats:PlayerStats) -> float:
		return float(100 - accuracy) / 100.0 * 90.0
		
	func getMinVariance(playerStats:PlayerStats) -> float:
		if accuracy >= 50: return 0.0
		return float(100 - (2 * accuracy)) / 100.0 * 90.0
		
	func getVarianceDuration(playerStats:PlayerStats, startVariance:float) -> float:
		return (startVariance - self.getMinVariance(playerStats)) / (self.getAimSpeed(playerStats) / 8)
		
	func getAimSpeed(playerStats:PlayerStats) -> float:
		var brawnsFactor = self.getBrawnsFactor(playerStats)
		return self.BASE_DEGREES_PER_SECOND * pow(max(float(10 - self.weight), 0.5), 1.5) / 31 * (1 / brawnsFactor)
		
	func getVarianceKickback(playerStats:PlayerStats) -> float:
		var brawnsFactor = self.getBrawnsFactor(playerStats)
		return float(self.kickback) * brawnsFactor
		
	func getAimKickback(playerStats:PlayerStats) -> float:
		var brawnsFactor = self.getBrawnsFactor(playerStats)
		var weightMod = pow(max(float(10 - self.weight), 0.5), 1.5) / 31 * brawnsFactor
		return float(self.kickback) / 10.0 * weightMod
