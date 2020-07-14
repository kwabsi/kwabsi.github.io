extends Node

signal currentNodes_changed()
signal zoom_changed()
signal game_speed_changed(newSpeed)

signal skills_changed()

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
	
func getPopulation():
	var _pop = 0
	for node in currentNodes:
		if node.properties.housingCapacity > 0:
			_pop += node.properties.housingCapacity
	return _pop
	
func getMaterials():
	return self.resources.getMaterials()
	
func getResearch():
	return self.resources.getResearch()
	
func getMaterialsPerSecond():
	var _mps:float = 0.0
	for node in currentNodes:
		_mps += node.properties.materialsPerSecond
	return _mps
	
func getResearchPerSecond():
	var _rps:float = 0.0
	for node in currentNodes:
		_rps += node.properties.researchPerSecond
	return _rps
	
func setGameSpeed(_newSpeed):
	Engine.time_scale = _newSpeed
	emit_signal("game_speed_changed", _newSpeed)

func destroyNode(_buildingNodeIndex:int):
	var _building = currentNodes[_buildingNodeIndex]
	_building.destroy()
	currentNodes.remove(_buildingNodeIndex)
	emit_signal("currentNodes_changed")

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		restart()
	if Input.is_action_just_pressed("ui_down"):
		destroyNode(randi() % len(currentNodes))
		
func restart():
	self.buildingNodeFactory = BuildingNodeFactory.new()
	self.skillProgress = Progress.new()
	self.resources = Resources.new(self)
	for child in currentNodes:
		child.queue_free()
	self.currentNodes = []
	for i in range(StartValues.startNodeCount):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.PASTURE, BuildingNodeFactory.PASTURE.WOODS))
	self.zoom = StartValues.startZoom
	emit_signal("currentNodes_changed")
	emit_signal("skills_changed")

func _init():
	restart()

class StartValues extends Object:
	const startNodeCount:int = 20
	const startZoom:float = 0.25
	
class Resources:
	var materials:int = 10
	var _trueMaterials:float = 10.0
	var research:int = 0
	var _trueResearch:float = 0.0
	
	var parent:Node
	
	func _init(_parent):
		parent = _parent
		
	func getMaterials() -> int:
		return materials
		
	func changeMaterials(_change:int):
		materials += _change
		_trueMaterials += _change
		
	func getResearch() -> int:
		return research
		
	func changeResearch(_change:int):
		research += _change
		_trueResearch += _change
	
