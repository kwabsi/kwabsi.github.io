extends Reference
class_name BuildingNodeFactory

enum TYPE { HOUSING, PRODUCTION, RESEARCH, PASTURE }
enum HOUSING { CAMP, VILLAGE, TOWN, CITY, METROPOLIS }
enum PRODUCTION { LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT }
enum RESEARCH { SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY }
enum PASTURE { WOODS }

var buildingPropertyDict = {
	TYPE.HOUSING: {
		HOUSING.CAMP: BuildingProperty.new(5, 0, 0, 1, 4, "res://instances/game/houses/Camp.tscn"),
		HOUSING.VILLAGE: BuildingProperty.new(10, 0, 0, 1, 25, "res://instances/game/houses/Village.tscn"),
		HOUSING.TOWN: BuildingProperty.new(25, 0, 0, 0, 0, ""),
		HOUSING.CITY: BuildingProperty.new(100, 0, 0, 0, 0, ""),
		HOUSING.METROPOLIS: BuildingProperty.new(300, 0, 0, 0, 0, ""),
	},
	TYPE.PRODUCTION: {
		PRODUCTION.LUMBERYARD: BuildingProperty.new(-5, 2, 0, 2, 6, "res://instances/game/production/Lumberyard.tscn"),
		PRODUCTION.MINE: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.REFINERY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.FACTORY: BuildingProperty.new(0, 0, 0, 0, 0, ""),
		PRODUCTION.PRODUCTIONPLANT: BuildingProperty.new(0, 0, 0, 0, 0, ""),
	},
	TYPE.RESEARCH: {
		RESEARCH.SCHOOL: BuildingProperty.new(-5, 0, 2, 0, 11, "res://instances/game/research/School.tscn"),
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
	var BuildingEffect = preload("res://instances/game/BuildingEffect.tscn")
	var DestructionEffect = preload("res://instances/game/DestructionEffect.tscn")
	
	var id:int
	var type:int
	var properties:BuildingProperty
	var visualNode:Node2D
	var tween:Tween
	
	func _init(_id:int, _type:int, _properties:BuildingProperty):
		id = _id
		type = _type
		setProperties(_properties)
		tween = Tween.new()
		add_child(tween)
		
	func setProperties(_properties:BuildingProperty):
		properties = _properties
		var _newNode = _properties.visualNode.instance()
		if (visualNode != null):
			var buildingEffect = BuildingEffect.instance()
			tween.remove_all()
			_newNode.position = visualNode.position
			_newNode.rotation = visualNode.rotation
			_newNode.add_child(buildingEffect)
			tween.interpolate_property(_newNode, "scale", Vector2(1, 0), Vector2.ONE, 1.0, Tween.TRANS_CUBIC)
			tween.start()
			visualNode.call_deferred("queue_free")
		visualNode = _newNode
		self.add_child(visualNode)
		
	func updateRadius(_radius:float):
		visualNode.position = Vector2(0, -1 * (_radius - CONSTANTS.NODE_DISTANCE / 4.0))
		
	func getBuildButtonPosition():
		if !is_inside_tree():
			return Vector2.ZERO
		return (((visualNode.global_position - GameState.camera.position) / GameState.camera.zoom) + GameState.camera.position
			+ Vector2(0, -1 * CONSTANTS.NODE_DISTANCE).rotated(self.global_rotation) / GameState.camera.zoom )

	func changeBuilding(_id:int, _type:int, _properties:BuildingProperty):
		id = _id
		type = _type
		setProperties(_properties)
		
	func destroy():
		if get_node_or_null("../../..") != null:
			var _destructionNode = DestructionEffect.instance()
			_destructionNode.global_position = visualNode.global_position
			_destructionNode.global_rotation = visualNode.global_rotation
			$"../../..".add_child(_destructionNode)
		call_deferred("queue_free")

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
