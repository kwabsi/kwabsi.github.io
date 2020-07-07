extends StateMachine
class_name SummonStateMachine

func _ready():
	pass

class State:
	var transitions:Array
	var behavior:Behavior
	
class Transition:
	var signalSource:Object
	var signalName:String
	var targetStateId:int
	var events:Array = []
	
class Event:
	var ref:FuncRef
	var args:Array = []
	
	func call_func(arguments:Array = []):
		return ref.call_funcv(args +  arguments)
	
class Behavior:
	var onEnter:Event
	var onProcess:Event
	var onExit:Event
	
	func _init(_onProcess:Event = null, _onEnter:Event = null, _onExit:Event = null):
		self.onEnter = _onEnter
		self.onProcess = _onProcess
		self.onExit = _onExit
	
