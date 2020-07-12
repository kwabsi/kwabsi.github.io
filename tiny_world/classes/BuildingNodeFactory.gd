extends Reference
class_name BuildingNodeFactory

enum TYPE { HOUSING, PRODUCTION, RESEARCH, PASTURE }
enum HOUSING { CAMP, VILLAGE, TOWN, CITY, METROPOLIS }
enum PRODUCTION { LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT }
enum RESEARCH { SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY }
enum PASTURE { WOODS }

var buildingPropertyDict = {
	TYPE.HOUSING: {
		HOUSING.CAMP: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		HOUSING.VILLAGE: BuildingProperty.new(0, 0, 0, 0, 0, "res://instances/game/houses/Village.tscn"),
		HOUSING.TOWN: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		HOUSING.CITY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		HOUSING.METROPOLIS: BuildingProperty.new(0, 0, 0, 0, 0, ""),
	},
	TYPE.PRODUCTION: {
		PRODUCTION.LUMBERYARD: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.MINE: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.REFINERY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.FACTORY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.PRODUCTIONPLANT: BuildingProperty.new(0, 0, 0, 0, 0, ""),
	},
	TYPE.RESEARCH: {
		RESEARCH.SCHOOL: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		RESEARCH.MUSEUM: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		RESEARCH.LIBRARY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		RESEARCH.COLLEGE: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		RESEARCH.UNIVERSITY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
	},
	TYPE.PASTURE: {
		PASTURE.WOODS: BuildingProperty.new(0, 0, 0, 0, 0, "res://instances/game/pastures/FreeSpace.tscn"),
	}
}

func build(type:int, id:int) -> BuildingNode:
	return BuildingNode.new(id, type, self.getBuildingData(type, id))

func getBuildingData(type:int, id:int) -> BuildingProperty:
	return buildingPropertyDict.get(type, {}).get(id, null)

class BuildingNode extends Node2D:
	var id:int
	var type:int
	var properties:BuildingProperty
	var visualNode:Node2D
	
	func _init(_id:int, _type:int, _properties:BuildingProperty):
		id = _id
		type = _type
		setProperties(_properties)
		
	func setProperties(_properties:BuildingProperty):
		properties = _properties
		if (visualNode != null):
			visualNode.call_deferred("queue_free")
		visualNode = _properties.visualNode.instance()
		self.add_child(visualNode)
		
	func updateRadius(_radius:float):
		visualNode.position = Vector2(0, -1 * (_radius - CONSTANTS.NODE_DISTANCE / 4.0))
		
	func getBuildButtonPosition():
		return (((visualNode.global_position - GameState.camera.position) / GameState.camera.zoom) + GameState.camera.position
			+ Vector2(0, -1 * CONSTANTS.NODE_DISTANCE).rotated(self.global_rotation) / GameState.camera.zoom )

class BuildingProperty:
	var housingCapacity:int = 0			# Negative means, that this many people can work there
	var materialsPerSecond:int = 0		# At full capacity
	var researchPerSecond:int = 0		# At full capacity
	var footPrint:int = 0
	var cost:int = 0
	var visualNode:PackedScene = null
	
	func _init(_h:int, _mps:int, _rps:int, _ftp:int, _cost:int, _visualNode:String):
		housingCapacity = _h
		materialsPerSecond = _mps
		researchPerSecond = _rps
		footPrint = _ftp
		cost = _cost
		visualNode = load(_visualNode)
