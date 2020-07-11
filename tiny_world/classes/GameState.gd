extends Node

signal currentNodesChanged()

var currentNodes:Array = []
var buildingNodeFactory:BuildingNodeFactory = BuildingNodeFactory.new()

func _process(_delta):
	if Input.is_action_just_pressed("ui_up"):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.HOUSING, BuildingNodeFactory.HOUSING.VILLAGE))
		emit_signal("currentNodesChanged")
	if Input.is_action_just_pressed("ui_down"):
		currentNodes.pop_front()
		emit_signal("currentNodesChanged")
		
func _init():
	for i in range(5):
		currentNodes.append(buildingNodeFactory.build(BuildingNodeFactory.TYPE.HOUSING, BuildingNodeFactory.HOUSING.VILLAGE))

class StartValues extends Object:
	const startNodeCount:int = 10
