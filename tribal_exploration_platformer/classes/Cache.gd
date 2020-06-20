extends Reference
class_name Cache

var size:int = 50 setget resize

var dict:Dictionary = {}
var cached:Array = []

func _init(_size:int = 50):
	self.size = _size
	
func loadFunc(filePath:String) -> Reference:
	return load(filePath)

func loadFromCache(filePath:String) -> Reference:
	if !dict.has(filePath):
		var _res = loadFunc(filePath)
		self.addToCache(filePath, _res)
		return _res
	return dict.get(filePath, null)

func addToCache(filePath:String, resource:Reference):
	dict[filePath] = loadFunc(filePath)
	cached.append(filePath)
	if len(cached) > self.size:
		var _oldest = cached.pop_front()
		dict.erase(_oldest)

func resize(_size):
	size = _size
	while len(cached) > self.size:
		var _oldest = cached.pop_front()
		dict.erase(_oldest)
