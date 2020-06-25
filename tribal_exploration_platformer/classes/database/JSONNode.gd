tool
extends Node
class_name JSONNode

var id:int = -1
var data:Data = Data.new()

func setID(value):
	print('SETID ', value)
	id = value
	
class Data extends Reference:
	func toJSON() -> Dictionary:
		return { }
		
	func fromJSON(json:Dictionary) -> Data:
		return self
