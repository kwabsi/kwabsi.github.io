extends Reference
class_name Progress

enum SKILLS { 
	CAMP, VILLAGE, TOWN, CITY, METROPOLIS,
	LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT,
	SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY,
	
	COMMUNITY
}

var skillDict = {}

func _init_skillDict():
	skillDict = {
		SKILLS.CAMP: Skill.new("Camp Building", "Allows you to build a camp.", 0),
		SKILLS.LUMBERYARD: Skill.new("Lumberyard Building", "Allows you to build a lumberyard.", 0),
		SKILLS.SCHOOL: Skill.new("School Building", "Allows you to build a school.", 0),
		SKILLS.VILLAGE: Skill.new("Village Building", "Allows you to build a village, which can hold more people than a camp.", 20, [SKILLS.CAMP]),
		SKILLS.TOWN: Skill.new("Town Building", "Allows you to build a town, which can hold more people than a village.", 100, [SKILLS.VILLAGE]),
		SKILLS.CITY: Skill.new("City Building", "Allows you to build a city, which can hold a lot more people than a town.", 200, [SKILLS.TOWN]),
		SKILLS.METROPOLIS: Skill.new("Metropolis Building", "Allows you to build really large cities for a huge amount of people, but also with a strong influence on the environment.", 500, [SKILLS.CITY]),
		SKILLS.MINE: Skill.new("Mine Building", "A mine to extract wealth straight from the planet.", 20, [SKILLS.LUMBERYARD]),
		SKILLS.REFINERY: Skill.new("Refinery Building", "A refinery, which directly drains the resources from the planet. Requires less people, but also creates more wealth.", 50, [SKILLS.MINE]),
		SKILLS.FACTORY: Skill.new("Factory Building", "A place stuff is turned into things.", 200, [SKILLS.REFINERY]),
		SKILLS.PRODUCTIONPLANT: Skill.new("Production Plant Building", "Produces a lot of wealth made by a lot of people.", 500, [SKILLS.FACTORY]),
		SKILLS.MUSEUM: Skill.new("Museum Building", "Preserve knowledge while fostering the thirst for more.", 100, [SKILLS.SCHOOL]),
		SKILLS.LIBRARY: Skill.new("Library Building", "A place to study the wisdom of the ages at your own pace.", 100, [SKILLS.MUSEUM]),
		SKILLS.COLLEGE: Skill.new("College Building", "Higher education for everybody.", 200, [SKILLS.LIBRARY]),
		SKILLS.UNIVERSITY: Skill.new("University Building", "A monument to knowledge and unfettered minds.", 500, [SKILLS.COLLEGE]),
		
		SKILLS.COMMUNITY: Skill.new("Community Spirit", "Foster a good spirit within your communities with local festivities and get-togethers. Increases Village Population by 50%", 100, [SKILLS.VILLAGE], funcref(parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.VILLAGE], "set"), ["housingCapacity", parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.VILLAGE].housingCapacity * 1.5])
	}

var parent:Node

func activateSkill(key:int):
	skillDict[key].learned = true
	if skillDict[key].onActivate != null:
		skillDict[key].onActivate.call_funcv(skillDict[key].onActivateParams)
	
func hasSkill(key:int) -> bool:
	if !skillDict.has(key):
		return false
	return skillDict.get(key).learned

func canLearn(key:int) -> bool:
	for skill in skillDict[key].prerequisites:
		if !hasSkill(skill):
			return false
	return true
	
func _init(_parent:Node):
	self.parent = _parent
	_init_skillDict()
	activateSkill(SKILLS.CAMP)
	activateSkill(SKILLS.LUMBERYARD)
	activateSkill(SKILLS.SCHOOL)
	
class Skill:
	var label:String
	var description:String
	var cost:int
	var prerequisites:Array
	var onActivate:FuncRef
	var onActivateParams:Array
	var learned:bool
	
	func _init(_label:String, _description:String, _cost:int, _prerequisites:Array = [], _onActivate:FuncRef = null, _onActivateParams:Array = []):
		label = _label
		description = _description
		cost = _cost
		prerequisites = _prerequisites
		onActivate = _onActivate
		onActivateParams = _onActivateParams
