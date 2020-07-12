extends Node

signal currentNodes_changed()
signal zoom_changed()

signal materials_changed()
signal research_changed()

var currentNodes:Array = []
var buildingNodeFactory:BuildingNodeFactory = BuildingNodeFactory.new()

var camera:Camera2D
var zoom:float = 0.5 setget setZoom

var paused = false

var skillProgress:Progress = Progress.new()
var resources:Resources = Resources.new(self)

func setZoom(_zoom:float):
	zoom = min(1, max(0, _zoom))
	emit_signal("zoom_changed")
	
func pause():
	if !paused:
		paused = true
		get_tree().paused = true
		
func unpause():
	if paused:
		paused = false
		get_tree().paused = false
	
func activateSkill(skillId:int):
	skillProgress.activateSkill(skillId)
		
func hasSkill(skillId:int) -> bool:
	return skillProgress.hasSkill(skillId)
	
func getBuildingCost(typeId:int, buildingId:int) -> int:
	var _buildingProps = buildingNodeFactory.getBuildingData(typeId, buildingId)
	return _buildingProps.cost

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.HOUSING, BuildingNodeFactory.HOUSING.VILLAGE))
		emit_signal("currentNodes_changed")
	if Input.is_action_just_pressed("ui_down"):
		currentNodes.remove(randi() % len(currentNodes))
		emit_signal("currentNodes_changed")
		
func _init():
	for i in range(10):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.PASTURE, BuildingNodeFactory.PASTURE.WOODS))

class StartValues extends Object:
	const startNodeCount:int = 10
	const startZoom:float = 0.5
	
class Resources:
	var materials:int = 0
	var _trueMaterials:float = 0.0
	var research:int = 0
	var _trueResearch:float = 0.0
	
	var parent:Node
	
	func _init(_parent):
		parent = _parent
		
	func getMaterials() -> int:
		return materials
		
	func changeMaterials(_change:int):
		materials -= _change
		_trueMaterials -= _change
	
