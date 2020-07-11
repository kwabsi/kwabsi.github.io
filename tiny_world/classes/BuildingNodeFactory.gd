extends Reference
class_name BuildingNodeFactory

enum TYPE { HOUSING, PRODUCTION, RESEARCH }
enum HOUSING { CAMP, VILLAGE, TOWN, CITY, METROPOLIS }
enum PRODUCTION { LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT }
enum RESEARCH { SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY }

var buildingPropertyDict = {
	TYPE.HOUSING: {
		HOUSING.CAMP: BuildingProperty.new(0, 0, 0, 0, ""),
		HOUSING.VILLAGE: BuildingProperty.new(0, 0, 0, 0, "res://assets/graphics/houses/village.png"),
		HOUSING.TOWN: BuildingProperty.new(0, 0, 0, 0, ""),
		HOUSING.CITY: BuildingProperty.new(0, 0, 0, 0, ""),
		HOUSING.METROPOLIS: BuildingProperty.new(0, 0, 0, 0, ""),
	},
	TYPE.PRODUCTION: {
		PRODUCTION.LUMBERYARD: BuildingProperty.new(0, 0, 0, 0, ""),
		PRODUCTION.MINE: BuildingProperty.new(0, 0, 0, 0, ""),
		PRODUCTION.REFINERY: BuildingProperty.new(0, 0, 0, 0, ""),
		PRODUCTION.FACTORY: BuildingProperty.new(0, 0, 0, 0, ""),
		PRODUCTION.PRODUCTIONPLANT: BuildingProperty.new(0, 0, 0, 0, ""),
	},
	TYPE.RESEARCH: {
		RESEARCH.SCHOOL: BuildingProperty.new(0, 0, 0, 0, ""),
		RESEARCH.MUSEUM: BuildingProperty.new(0, 0, 0, 0, ""),
		RESEARCH.LIBRARY: BuildingProperty.new(0, 0, 0, 0, ""),
		RESEARCH.COLLEGE: BuildingProperty.new(0, 0, 0, 0, ""),
		RESEARCH.UNIVERSITY: BuildingProperty.new(0, 0, 0, 0, ""),
	}
}

func build(type:int, id:int) -> BuildingNode:
	return BuildingNode.new(self.getBuildingData(type, id))

func getBuildingData(type:int, id:int) -> BuildingProperty:
	print(type, " === ", id, " === ", buildingPropertyDict)
	return buildingPropertyDict.get(type, {}).get(id, null)

class BuildingNode:
	const SMOOTHNESS = 8
	
	var properties:BuildingProperty
	var lineNode:Line2D
	
	func _init(_properties:BuildingProperty):
		lineNode = Line2D.new()
		lineNode.default_color = Color.white
		lineNode.joint_mode = Line2D.LINE_JOINT_BEVEL
		lineNode.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		setProperties(_properties)
		
	func setProperties(_properties:BuildingProperty):
		properties = _properties
		lineNode.texture = _properties.texture
		lineNode.width = float(lineNode.texture.get_height()) / 2.0
		
	func updateRadius(_radius:float):
		var _points = PoolVector2Array()
		var _targetRad = float(CONSTANTS.NODE_DISTANCE) / _radius
		for i in range(SMOOTHNESS + 1):
			var _anglePoint = i * _targetRad / SMOOTHNESS
			_points.push_back(Vector2(cos(_anglePoint), sin(_anglePoint)) * (_radius + (lineNode.width / 2)))
		lineNode.points = _points

class BuildingProperty:
	var housingCapacity:int = 0			# Negative means, that this many people can work there
	var materialsPerSecond:int = 0		# At full capacity
	var researchPerSecond:int = 0		# At full capacity
	var footPrint:int = 0
	var texture:Texture = null
	
	func _init(_h:int, _mps:int, _rps:int, _ftp:int, _texture:String):
		housingCapacity = _h
		materialsPerSecond = _mps
		researchPerSecond = _rps
		footPrint = _ftp
		texture = load(_texture)
