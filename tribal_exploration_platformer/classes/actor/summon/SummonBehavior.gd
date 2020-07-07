extends Node
class_name SummonBehavior

var parent:Node2D = null

func init(id, _parent):
	self.parent = _parent
	self.parent.connect("tree_entered", self, "_on_self_init", [id])

func _on_enter(previousState):
	pass
	
func _on_process(delta):
	pass
	
# Called by Player
func _on_trigger():
	pass

func _on_exit(nextState):
	pass
	
func _on_self_init(id):
	self.parent.add_child(self)
	self.parent.stateMachine.registerState(id, funcref(self, "_on_process"), funcref(self, "_on_enter"), funcref(self, "_on_exit"))
