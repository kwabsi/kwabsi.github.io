extends Node

signal currentNodes_changed()
signal zoom_changed()
signal game_speed_changed(newSpeed)
signal game_paused_changed()
signal notification(text)

signal skills_changed()

var currentNodes:Array = []
var buildingNodeFactory:BuildingNodeFactory = BuildingNodeFactory.new()

var camera:Camera2D
var zoom:float = 0.5 setget setZoom

var paused = false

var skillProgress:Progress = Progress.new(self)
var resources:Resources = Resources.new(self)
var notifications:Notifications = Notifications.new(self)

var populationWeight:float = 0.5

var capacityPerNode:float = 3.0
var _currentPollution:float = 0.0

func setZoom(_zoom:float):
	zoom = min(1, max(0, _zoom))
	emit_signal("zoom_changed")
	
func pause():
	if !paused:
		paused = true
		get_tree().paused = true
		emit_signal("game_paused_changed")
		
func unpause():
	if paused:
		paused = false
		get_tree().paused = false
		emit_signal("game_paused_changed")
	
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

func getMaterialPercent():
	var _pop = float(getPopulation())
	var _requiredPop:float = 0.0
	for node in currentNodes:
		if node.properties.materialsPerSecond > 0 && node.properties.housingCapacity < 0:
			_requiredPop -= node.properties.housingCapacity
	if _requiredPop == 0:
		return 1.0
	return min(1.0, (_pop * (1.0 - populationWeight)) / _requiredPop)
	
func getResearchPercent():
	var _pop = float(getPopulation())
	var _requiredPop:float = 0.0
	for node in currentNodes:
		if node.properties.researchPerSecond > 0 && node.properties.housingCapacity < 0:
			_requiredPop -= node.properties.housingCapacity
	if _requiredPop == 0:
		return 1.0
	return min(1.0, (_pop * (populationWeight)) / _requiredPop)

func getMaterialsPerSecond():
	var _mps:float = 0.0
	for node in currentNodes:
		_mps += node.properties.materialsPerSecond
	return _mps * getMaterialPercent()
	
func getResearchPerSecond():
	var _rps:float = 0.0
	for node in currentNodes:
		_rps += node.properties.researchPerSecond
	return _rps * getResearchPercent()
	
func getPollutionPerSecond() -> float:
	var _pps:float = 0.0
	for node in currentNodes:
		_pps += node.properties.footPrint
	return float(_pps)
	
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
		
func _physics_process(delta):
	var _rps = getResearchPerSecond()
	var _mps = getMaterialsPerSecond()
	var _pps = getPollutionPerSecond()
	self.resources.changeMaterials(_mps * delta)
	self.resources.changeResearch(_rps * delta)
	_currentPollution += _pps * delta
	if _currentPollution >= len(currentNodes) * capacityPerNode:
		_currentPollution -= len(currentNodes) * capacityPerNode
		destroyNode(randi() % len(currentNodes))
		
func restart(reloadTree = true):
	self.capacityPerNode = StartValues.capacityPerNode
	self.buildingNodeFactory = BuildingNodeFactory.new()
	self.skillProgress = Progress.new(self)
	self.resources = Resources.new(self)
	self.notifications = Notifications.new(self)
	for child in currentNodes:
		child.call_deferred("queue_free")
	self.currentNodes = []
	for i in range(StartValues.startNodeCount):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.PASTURE, BuildingNodeFactory.PASTURE.WOODS))
	self.zoom = StartValues.startZoom
	emit_signal("currentNodes_changed")
	emit_signal("skills_changed")

func _init():
	restart(false)
	
func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self.notifications, "send", [Notifications.INDEX.WELCOME])
	timer.connect("timeout", timer, "queue_free")
	timer.start(2)

class StartValues extends Object:
	const startNodeCount:int = 20
	const startZoom:float = 0.25
	const capacityPerNode:float = 10.0
	
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
		
	func changeMaterials(_change:float):
		_trueMaterials += _change
		materials = int(floor(_trueMaterials))
		
	func getResearch() -> int:
		return research
		
	func changeResearch(_change:float):
		_trueResearch += _change
		research = int(floor(_trueResearch))
	
