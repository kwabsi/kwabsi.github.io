tool
extends Node
class_name Database

const DIR = 'res://database/'
const USER_DIR = 'user://'

export var save:bool = false setget saveDatabase
export var folder:String = ''
export(GDScript) var nodeClass:GDScript
export(GDScript) var metaClass:GDScript
export var cacheSize:int = 50
export var isUserDB:bool = false
var cache:JSONCache = JSONCache.new()

var lastId:int = 1 setget ,getNextId
var metaData:MetaData

# ============= ACTUAL DATABASE USE ====================
func find(id:int) -> JSONNode.Data:
	var filePath = self.getPath() + String(id) + '.json'
	var result = cache.loadFromCache(filePath)
	return result

func insert(data:JSONNode.Data) -> int:
	if !self.isUserDB:
		return -1
	var node = self.nodeClass.new()
	var _id = self.getNextId()
	node.id = _id
	node.name = String(_id)
	node.data = data
	self.saveNode(node)
	return _id
	
func update(id:int, data:JSONNode.Data):
	if !self.isUserDB:
		return
	var node = self.nodeClass.new()
	node.id = id
	node.name = String(id)
	node.data = data
	self.saveNode(node)

# ============== INTERNAL DATABASE STUFF ================
func getNextId() -> int:
	metaData.lastId += 1
	return metaData.lastId

func getPath():
	if self.isUserDB:
		return USER_DIR + 'data/' + 'files/' + folder + '/'
	return DIR + folder + '/'
		
func saveDatabase(__):
	save = true
	var directory:Directory = Directory.new()
	directory.make_dir_recursive(self.getPath())
	for child in get_children():
		self.saveNode(child)
	save = false
	
func saveNode(node:JSONNode):
	var filePath = self.getPath() + String(node.id) + ".json"
	var file = File.new()
	file.open(filePath, File.WRITE)
	var json = node.data.toJSON()
	json['id'] = node.id
	json['name'] = node.name
	file.store_string(JSON.print(json))
	file.close()

func loadDatabase():
	var directory:Directory = Directory.new()
	var dir = self.getPath()
	if directory.open(dir) == OK:
		directory.list_dir_begin(true)
		var fileName = directory.get_next()
		while fileName != '':
			if fileName.ends_with('.json'):
				self.loadNode(dir + fileName)
			fileName = directory.get_next()

func loadNode(filePath:String):
	var file = File.new()
	file.open(filePath, File.READ)
	var parseResult = JSON.parse(file.get_as_text())
	file.close()
	if parseResult.error == OK:
		var jsonNode = nodeClass.new()
		jsonNode.data.fromJSON(parseResult.result)
		jsonNode.id = parseResult.result.get("id", -1)
		jsonNode.name = parseResult.result.get("name", "DEFAULT")
		add_child(jsonNode, true)
		jsonNode.set_owner(get_tree().get_edited_scene_root())
	else:
		print('ERROR READING JSON DATA FROM ' + filePath + ' : ' + parseResult.error_string)

func createUserFolder():
	if !self.isUserDB:
		return
	var directory:Directory = Directory.new()
	directory.make_dir_recursive(self.getPath())

func reload():
	for child in get_children():
		remove_child(child)
		child.queue_free()
	loadDatabase()

func _ready():
	if Engine.is_editor_hint():
		reload()
	else:
		self.cache.init(self.nodeClass)
		self.cache.resize(self.cacheSize)
		if self.isUserDB:
			self.createUserFolder()
			self.loadMetaData()
		
func _exit_tree():
	if !Engine.is_editor_hint() && self.isUserDB:
		self.saveMetaData()

# ==================== META DATA =======================
# ONLY FOR USER DATA
func getMetaDataFilePath() -> String:
	return USER_DIR + 'data/' + 'meta/'

func loadMetaData():
	var meta = metaClass.new()
	var file = File.new()
	if file.open(self.getMetaDataFilePath() + self.folder + '.json', File.READ) == OK:
		var parseResult = JSON.parse(file.get_as_text())
		file.close()
		if parseResult.error == OK:
			meta.fromJSON(parseResult.result)
	self.metaData = meta
	
func saveMetaData():
	var directory:Directory = Directory.new()
	if !directory.dir_exists(self.getMetaDataFilePath()):
		directory.make_dir_recursive(self.getMetaDataFilePath())
	var file = File.new()
	if file.open(self.getMetaDataFilePath() + self.folder + '.json', File.WRITE) == OK:
		file.store_string(JSON.print(self.metaData.toJSON()))
		file.close()
		
class JSONCache extends Cache:
	var nodeClass:GDScript
	
	func init(_nodeClass):
		self.nodeClass = _nodeClass
		
	func loadFunc(filePath:String) -> Reference:
		var jsonNode = self.nodeClass.new()
		var data = jsonNode.data
		jsonNode.queue_free()
		var file = File.new()
		file.open(filePath, File.READ)
		var parseResult = JSON.parse(file.get_as_text())
		file.close()
		if parseResult.error == OK:
			data.fromJSON(parseResult.result)
		return data
