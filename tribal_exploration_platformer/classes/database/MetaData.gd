extends Reference
class_name MetaData

var lastId:int

func fromJSON(json:Dictionary):
	self.lastId = json.get("lastId", 0)
	
func toJSON() -> Dictionary:
	return {
		'lastId': self.lastId,
	}
