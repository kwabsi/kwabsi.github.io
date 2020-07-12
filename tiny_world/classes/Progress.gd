extends Reference
class_name Progress

enum SKILLS { 
	CAMP, VILLAGE, TOWN, CITY, METROPOLIS,
	LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT,
	SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY,
}

var skillDict = {
	SKILLS.CAMP: Skill.new("Camp Building", "Allows you to build a camp."),
	SKILLS.LUMBERYARD: Skill.new("Lumberyard Building", "Allows you to build a lumberyard."),
	SKILLS.SCHOOL: Skill.new("School Building", "Allows you to build a school."),
	SKILLS.VILLAGE: Skill.new("Village Building", "Allows you to build a village, which can hold more people than a camp.", [SKILLS.CAMP]),
	SKILLS.TOWN: Skill.new("Town Building", "Allows you to build a town, which can hold more people than a village.", [SKILLS.VILLAGE]),
	SKILLS.CITY: Skill.new("City Building", "Allows you to build a city, which can hold a lot more people than a town.", [SKILLS.TOWN]),
	SKILLS.METROPOLIS: Skill.new("Metropolis Building", "Allows you to build really large cities for a huge amount of people, but also with a strong influence on the environment.", [SKILLS.CITY]),
	SKILLS.MINE: Skill.new("Mine Building", "A mine to extract wealth straight from the planet.", [SKILLS.LUMBERYARD]),
	SKILLS.REFINERY: Skill.new("Refinery Building", "A refinery, which directly drains the resources from the planet. Requires less people, but also creates more wealth.", [SKILLS.MINE]),
	SKILLS.FACTORY: Skill.new("Factory Building", "A place stuff is turned into things.", [SKILLS.REFINERY]),
	SKILLS.PRODUCTIONPLANT: Skill.new("Production Plant Building", "Produces a lot of wealth made by a lot of people.", [SKILLS.FACTORY]),
	SKILLS.MUSEUM: Skill.new("Museum Building", "Preserve knowledge while fostering the thirst for more.", [SKILLS.SCHOOL]),
	SKILLS.LIBRARY: Skill.new("Library Building", "A place to study the wisdom of the ages at your own pace.", [SKILLS.MUSEUM]),
	SKILLS.COLLEGE: Skill.new("College Building", "Higher education for everybody.", [SKILLS.LIBRARY]),
	SKILLS.UNIVERSITY: Skill.new("University Building", "A monument to knowledge and unfettered minds.", [SKILLS.COLLEGE]),
}

func activateSkill(key:int):
	skillDict[key].learned = true
	
func hasSkill(key:int) -> bool:
	if !skillDict.has(key):
		return false
	return skillDict.get(key).learned
	
func _init():
	activateSkill(SKILLS.CAMP)
	activateSkill(SKILLS.LUMBERYARD)
	activateSkill(SKILLS.SCHOOL)

class Skill:
	var label:String
	var description:String
	var prerequisites:Array
	var learned:bool
	
	func _init(_label:String, _description:String, _prerequisites:Array = []):
		label = _label
		description = _description
		prerequisites = _prerequisites
