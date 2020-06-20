extends JSONNode

export var characterName:String setget setCharacterName, getCharacterName
export var statistics:int
export var something:String

func setCharacterName(_characterName):
	self.data.characterName = _characterName
	
func getCharacterName():
	return self.data.characterName

class Data extends JSONNode.Data:
	var characterName:String
	var statistics:int
	var something:String
	
	func toJSON() -> Dictionary:
		return {
			'characterName': characterName,
			'statistics': statistics,
			'something': something
		}
		
	func fromJSON(json:Dictionary) -> JSONNode.Data:
		characterName = json.get('characterName', 'Peter')
		statistics = json.get('statistics', -1)
		something = json.get('something', 'Stuff')
		return self
