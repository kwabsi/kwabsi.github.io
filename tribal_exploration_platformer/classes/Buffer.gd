extends Node
class_name Buffer

var length:float = 0.2

var buffer:Dictionary = {}

func consume(key) -> bool:
	if buffer.has(key):
		buffer[key].call_deferred("queue_free")
		buffer.erase(key)
		return true
	return false

func check(key) -> bool:
	return buffer.has(key)
	
func insert(key, _length:float = self.length):
	if buffer.has(key):
		buffer[key].stop()
		buffer[key].start(_length)
	else:
		var timer = Timer.new()
		timer.connect("timeout", self, "_on_timeout", [key])
		buffer[key] = timer
		add_child(timer)
		timer.start(_length)
		
func _on_timeout(key):
	consume(key)

func _init(parent:Node, _length = 0.2):
	self.length = _length
	parent.connect("tree_entered", self, "_on_tree_entered", [parent])
	
func _on_tree_entered(parent):
	parent.add_child(self)
