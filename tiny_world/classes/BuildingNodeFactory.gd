extends Reference
class_name BuildingNodeFactory

enum TYPE { HOUSING, PRODUCTION, RESEARCH, PASTURE }
enum HOUSING { CAMP, VILLAGE, TOWN, CITY, METROPOLIS }
enum PRODUCTION { LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT }
enum RESEARCH { SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY }
enum PASTURE { WOODS }

var buildingPropertyDict = {
	TYPE.HOUSING: {
		HOUSING.CAMP: BuildingProperty.new(5, 0, 0, 1, 10, "res://instances/game/houses/Camp.tscn"),
		HOUSING.VILLAGE: BuildingProperty.new(10, 0, 0, 1, 30, "res://instances/game/houses/Village.tscn"),
		HOUSING.TOWN: BuildingProperty.new(30, 0, 0, 3, 100, "res://instances/game/houses/Town.tscn"),
		HOUSING.CITY: BuildingProperty.new(60, 0, 0, 5, 300, "res://instances/game/houses/City.tscn"),
		HOUSING.METROPOLIS: BuildingProperty.new(200, 0, 0, 15, 1000, "res://instances/game/houses/Metropolis.tscn"),
	},
	TYPE.PRODUCTION: {
		PRODUCTION.LUMBERYARD: BuildingProperty.new(-5, 2, 0, 1, 10, "res://instances/game/production/Lumberyard.tscn"),
		PRODUCTION.MINE: BuildingProperty.new(-20, 10, 0, 5, 30, "res://instances/game/production/Mine.tscn"),
		PRODUCTION.REFINERY: BuildingProperty.new(-5, 20, 0, 20, 50, "res://instances/game/production/Refinery.tscn"),
		PRODUCTION.FACTORY: BuildingProperty.new(-20, 50, 0, 20, 500, "res://instances/game/production/Factory.tscn"),
		PRODUCTION.PRODUCTIONPLANT: BuildingProperty.new(-60, 100, 0, 50, 2000, "res://instances/game/production/ProductionPlant.tscn"),
	},
	TYPE.RESEARCH: {
		RESEARCH.SCHOOL: BuildingProperty.new(-5, 0, 2, 0, 20, "res://instances/game/research/School.tscn"),
		RESEARCH.MUSEUM: BuildingProperty.new(-2, 0, 2, 0, 60, "res://instances/game/research/Museum.tscn"),
		RESEARCH.LIBRARY: BuildingProperty.new(-2, 0, 5, 0, 120, "res://instances/game/research/Library.tscn"),
		RESEARCH.COLLEGE: BuildingProperty.new(-50, 0, 30, 0, 300, "res://instances/game/research/College.tscn"),
		RESEARCH.UNIVERSITY: BuildingProperty.new(-100, 0, 70, 0, 2000, "res://instances/game/research/University.tscn"),
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
