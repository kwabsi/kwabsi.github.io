extends Node
class_name StateMachine

signal state_changed(newStateId, oldStateId)

enum MODE { IDLE, PHYSICS, CUSTOM }

var instance:Node = null
var mode:int = MODE.PHYSICS setget setMode
var current:int = -1 setget setState, getState
var stateDict:Dictionary = {}
var paused = false setget pause

func _init(_instance:Node, _mode:int = MODE.PHYSICS):
	self.instance = _instance
	self.mode = _mode
	self.instance.connect("tree_entered", self, "_on_instance_entered_tree")

func run(delta:float = 1.0):
	if stateDict.has(current) && stateDict[current].onProcess != null:
		stateDict[current].onProcess.call_func(delta)
		
func registerState(_stateId:int, _onProcess:FuncRef, _onEnter:FuncRef = null, _onExit:FuncRef = null):
	stateDict[_stateId] = State.new(_onProcess, _onEnter, _onExit)
	
func pause(_paused:bool = true):
	paused = _paused

func setMode(_mode:int):
	mode = _mode
	match mode:
		MODE.IDLE:
			set_process(true)
			set_physics_process(false)
		MODE.PHYSICS:
			set_process(false)
			set_physics_process(true)
		MODE.CUSTOM:
			set_process(false)
			set_physics_process(false)

func setState(_stateId:int, _performEnter:bool = true, _performExit:bool = true):
	var _old = current
	if _performExit && stateDict.has(current) && stateDict[current].onExit != null:
		var _res = stateDict[current].onExit.call_func(_stateId)
		if _res != null && _res is GDScriptFunctionState:
			yield(_res, "completed")
	current = _stateId
	if _performEnter && stateDict.has(current) && stateDict[current].onEnter != null:
		var _res = stateDict[current].onEnter.call_func(_old)
		if _res != null && _res is GDScriptFunctionState:
			yield(_res, "completed")
	emit_signal("state_changed", current, _old)

func getState():
	return current

func _process(delta):
	run(delta)
		
func _physics_process(delta):
	run(delta)

func _on_instance_entered_tree():
	self.instance.add_child(self)

class State:
	var onEnter:FuncRef = null		# func(oldStateId or -1) -> GDScriptFunctionState or null
	var onProcess:FuncRef = null		# func(delta) -> null
	var onExit:FuncRef = null			# func(nextStateId or -1) -> GDScriptFunctionState or null
	
	func _init(_onProcess, _onEnter, _onExit):
		onEnter = _onEnter
		onProcess = _onProcess
		onExit = _onExit
