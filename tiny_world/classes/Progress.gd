extends Reference
class_name Progress

enum SKILLS { 
	CAMP, VILLAGE, TOWN, CITY, METROPOLIS,
	LUMBERYARD, MINE, REFINERY, FACTORY, PRODUCTIONPLANT,
	SCHOOL, MUSEUM, LIBRARY, COLLEGE, UNIVERSITY,
	
	COMMUNITY, GARDEN, PARKS, PUBLIC_TRANSPORTATION,
	RIGHT_VIOLATION, FRACKING, SWEATSHOPS, CHILD_LABOUR,
	ACTIVITIES, GUIDES, READING_CLUBS, OPTIONAL_COURSES, FACILITIES,
	
	ETHICAL_MINING, CLEAN_OIL,
	
	ENVIRONMENTAL_RESEARCH, ADVANCED_ENVIRONMENTAL_RESEARCH,
	CLEAN_ENERGY, WASTE_MANAGEMENT, GREEN_LAWS, FACTORY_ACCOUNTABILITY,
	REFORESTATION, NATURE_RESERVES, TERRAFORMING, ATOMIC_ENERGY, CLEANER_ENERGY,
	GREEN_ZEITGEIST,
	
	BRIGHT_FUTURE,
	
	DOOMSDAY_CLOCK,
	
	FLG_ENVIRONMENT, FLG_CLEAN, FLG_CORRUPTABLE
}

var skillDict = {}

func _init_skillDict():
	skillDict = {
		SKILLS.ENVIRONMENTAL_RESEARCH: Skill.new("Environmental Research", "Start the research to save your planet.", 10, [SKILLS.FLG_ENVIRONMENT]),
		SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH: Skill.new("Advanced Research", "Open up new options to save your planet.", 200, [SKILLS.ENVIRONMENTAL_RESEARCH]),
		SKILLS.DOOMSDAY_CLOCK: Skill.new("Doomsday Clock", "Show a timer, that ticks down to the next natural disaster.", 50, [SKILLS.ENVIRONMENTAL_RESEARCH]),
		
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
		SKILLS.MUSEUM: Skill.new("Museum Building", "Preserve knowledge while fostering the thirst for more.", 20, [SKILLS.SCHOOL]),
		SKILLS.LIBRARY: Skill.new("Library Building", "A place to study the wisdom of the ages at your own pace.", 20, [SKILLS.MUSEUM]),
		SKILLS.COLLEGE: Skill.new("College Building", "Higher education for everybody.", 100, [SKILLS.LIBRARY]),
		SKILLS.UNIVERSITY: Skill.new("University Building", "A monument to knowledge and unfettered minds.", 500, [SKILLS.COLLEGE]),
		
		SKILLS.COMMUNITY: Skill.new("Community Spirit", "Foster a good spirit within your communities with local festivities and get-togethers. Increases Village Population by 50%", 100, [SKILLS.VILLAGE], funcref(parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.VILLAGE], "set"), ["housingCapacity", parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.VILLAGE].housingCapacity * 1.5]),
		SKILLS.GARDEN: Skill.new("Rentable Gardens", "Create dedicated places for your people to live the village life inside your towns. Increase Town Population by 50%, but also increase the cost of building new ones by 50%", 200, [SKILLS.TOWN], funcref(self, "_skill_garden")),
		SKILLS.PARKS: Skill.new("Parks and Recreation", "Make Cities more attractive to live in by building more parks. Increase City Population by 50% and decrease pollution by 20%", 200, [SKILLS.CITY, SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_parks")),
		SKILLS.PUBLIC_TRANSPORTATION: Skill.new("Public Transportation", "Invest in busses and trains to decrease pollution. Decrease City and Metropolis pollution by 50%.", 1000, [SKILLS.METROPOLIS, SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_public_transport")),
		
		SKILLS.RIGHT_VIOLATION: Skill.new("Human Right Violation", "Ignore a few suggestions made by law to improve profit. Decrease required Population of Mines by 25%.", 10, [SKILLS.MINE, SKILLS.FLG_CORRUPTABLE], funcref(self, "_skill_right_violation")),
		SKILLS.FRACKING: Skill.new("Hydraulic Fracturing", "Research new ways to make your Refineries more profitable. Increase everything Refineries produce by 20%.", 20, [SKILLS.REFINERY, SKILLS.FLG_CORRUPTABLE], funcref(self, "_skill_fracking")),
		SKILLS.SWEATSHOPS: Skill.new("Sweatshops", "Cut corners and rise to the top. Increase everything Factories produce by 40% and decrease the required population by 20%.", 40, [SKILLS.FACTORY, SKILLS.RIGHT_VIOLATION], funcref(self, "_skill_sweatshops")),
		SKILLS.CHILD_LABOUR: Skill.new("Child Labour", "Tap into the untapped market of young people to fill your production chains. Increase profits of Factories and Production Plants by 20% and decrease required Population by 20%.", 200, [SKILLS.PRODUCTIONPLANT, SKILLS.SWEATSHOPS], funcref(self, "_skill_child_labour")),
	
		SKILLS.ETHICAL_MINING: Skill.new("Ethical Mining", "Implement proper safety precautions for your mines. Decrease Pollution of Mines by 50%, but also decrease Material production by 30%.", 100, [SKILLS.ENVIRONMENTAL_RESEARCH, SKILLS.MINE, SKILLS.FLG_CLEAN], funcref(self, "_skill_ethical_mining")),
		SKILLS.CLEAN_OIL: Skill.new("Clean Oil", "Discover ways of making oil extraction safer and consumption cleaner. Decrease Pollution of Refineries by 50%, but also increase the required population by 200%.", 100, [SKILLS.ENVIRONMENTAL_RESEARCH, SKILLS.REFINERY, SKILLS.FLG_CLEAN], funcref(self, "_skill_clean_oil")),
	
		SKILLS.ACTIVITIES: Skill.new("Out of School Activities", "Invest into out of school activities to awaken interests early. Increase Research Speed of Schools by 40%.", 20, [SKILLS.SCHOOL], funcref(self, "_skill_activities")),
		SKILLS.GUIDES: Skill.new("Interactive Tour Guides", "Make museum tours more exciting and interesting by employing tour guides. Increase Research Speed of Museums by 40%.", 100, [SKILLS.MUSEUM], funcref(self, "_skill_guides")),
		SKILLS.READING_CLUBS: Skill.new("Reading Club", "Establish reading clubs in your library. Increase Research Speed of Libraries by 40%.", 100, [SKILLS.LIBRARY], funcref(self, "_skill_reading_clubs")),
		SKILLS.OPTIONAL_COURSES: Skill.new("Optional Classes", "Provide a variety of optional modules for the students. Increase Research Speed of Colleges by 40%.", 300, [SKILLS.COLLEGE], funcref(self, "_skill_optional_courses")),
		SKILLS.FACILITIES: Skill.new("Science Facilities", "Invest further in your universities to allow science to happen . Increase Research Speed of Universities by 40%.", 1000, [SKILLS.UNIVERSITY], funcref(self, "_skill_facilities")),
	
		SKILLS.CLEAN_ENERGY: Skill.new("Clean Energy", "Develop and deploy clean ways to generate electricity. Decrease Pollution by 10%.", 40, [SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_clean_energy")),
		SKILLS.WASTE_MANAGEMENT: Skill.new("Waste Management", "Research ways to safely and cleanly dispose of waste. Decrease Pollution by 10%.", 80, [SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_waste_management")),
		SKILLS.GREEN_LAWS: Skill.new("Green Laws", "Enforce Laws that protect the environment. Decrease Pollution by 20%, but also decrease overall material production by 10%.", 120, [SKILLS.ENVIRONMENTAL_RESEARCH, SKILLS.FLG_CLEAN, SKILLS.CITY], funcref(self, "_skill_green_laws")),
		SKILLS.FACTORY_ACCOUNTABILITY: Skill.new("Factory Accountability", "Force factory owners to optimize production chains by creating additional laws. Decrease Pollution by 40%, but also decrease overall material production by 50%.", 1000, [SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH, SKILLS.FACTORY], funcref(self, "_skill_factory_accountability")),
	
		SKILLS.REFORESTATION: Skill.new("Reforestation", "Replant trees and reinvigorate nature. Increases Pollution Capacity by 20%.", 200, [SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_reforestation")),
		SKILLS.NATURE_RESERVES: Skill.new("Nature Reserves", "Declare parts of the planet as nature reserves. Increases Pollution Capacity by 50%, but immediately let the planet shrink once.", 300, [SKILLS.ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_nature_reserves")),
		SKILLS.TERRAFORMING: Skill.new("Terraforming", "Meticulously shape the environment to make it more resistant to further disasters. Increases Pollution Capacity by 50%.", 1000, [SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_terraforming")),
		SKILLS.ATOMIC_ENERGY: Skill.new("Atomic Energy", "Decrease pollution by 50%, but each time a Housing Building get's destroyed by natural disaster, the planet will shrink two additional times.", 200, [SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH], funcref(self, "_skill_atomic_energy")),
		SKILLS.CLEANER_ENERGY: Skill.new("Cleaner Energy", "Bring theorethical machineries beyond scientists wildest dreams to life. Decrease pollution by 20%.", 1000, [SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH, SKILLS.CLEAN_ENERGY], funcref(self, "_skill_cleaner_energy")),
		SKILLS.GREEN_ZEITGEIST: Skill.new("Green Zeitgeist", "Increase awareness in the people about environment and nurture a society, which wants to preserve nature. Decrease pollution by 20%.", 1000, [SKILLS.ADVANCED_ENVIRONMENTAL_RESEARCH, SKILLS.CITY], funcref(self, "_skill_green_zeitgeist")),

		SKILLS.BRIGHT_FUTURE: Skill.new("Bright Future", "End climate change.", 5000, [SKILLS.GREEN_ZEITGEIST, SKILLS.CLEANER_ENERGY, SKILLS.FACTORY_ACCOUNTABILITY, SKILLS.TERRAFORMING, SKILLS.FACILITIES], funcref(self, "_skill_bright_future")),
		SKILLS.FLG_ENVIRONMENT: Skill.new("EnvFlag", "You shouldn't see this.", 0, [-1]),
		SKILLS.FLG_CLEAN: Skill.new("CleanFlag", "You shouldn't see this.", 0, [-1]),
		SKILLS.FLG_CORRUPTABLE: Skill.new("CorruptFlag", "You shouldn't see this.", 0, [-1]),
	}

var parent:Node

func activateSkill(key:int):
	skillDict[key].learned = true
	if skillDict[key].onActivate != null:
		skillDict[key].onActivate.call_funcv(skillDict[key].onActivateParams)
	parent.emit_signal("skills_changed")
	
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
	activateSkill(SKILLS.FLG_CLEAN)
	activateSkill(SKILLS.FLG_CORRUPTABLE)
	
func _skill_parks():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].housingCapacity = floor(1.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].housingCapacity)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].footPrint = ceil(0.8 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].footPrint)

func _skill_garden():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.TOWN].housingCapacity = floor(1.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.TOWN].housingCapacity)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.TOWN].cost = ceil(1.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.TOWN].cost)

func _skill_public_transport():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].footPrint = ceil(0.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.CITY].footPrint)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.METROPOLIS].footPrint = ceil(0.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.HOUSING][BuildingNodeFactory.HOUSING.METROPOLIS].footPrint)
	
func _skill_right_violation():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].housingCapacity = floor(0.75 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].housingCapacity)

func _skill_fracking():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].footPrint = ceil(1.2 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].footPrint)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].materialsPerSecond = floor(1.2 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].materialsPerSecond)

func _skill_sweatshops():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].footPrint = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].footPrint)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].materialsPerSecond = floor(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].materialsPerSecond)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].housingCapacity = ceil(0.8 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].housingCapacity)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].footPrint = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].footPrint)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].materialsPerSecond = floor(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].materialsPerSecond)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].housingCapacity = ceil(0.8 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].housingCapacity)

func _skill_child_labour():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].materialsPerSecond = floor(1.2 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].materialsPerSecond)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].housingCapacity = ceil(0.8 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.FACTORY].housingCapacity)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].materialsPerSecond = floor(1.2 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].materialsPerSecond)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].housingCapacity = ceil(0.8 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.PRODUCTIONPLANT].housingCapacity)
	skillDict[SKILLS.FLG_CLEAN].learned = false

func _skill_activities():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.SCHOOL].researchPerSecond = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.SCHOOL].researchPerSecond)

func _skill_guides():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.MUSEUM].researchPerSecond = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.MUSEUM].researchPerSecond)

func _skill_reading_clubs():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.LIBRARY].researchPerSecond = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.LIBRARY].researchPerSecond)

func _skill_optional_courses():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.COLLEGE].researchPerSecond = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.COLLEGE].researchPerSecond)

func _skill_facilities():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.UNIVERSITY].researchPerSecond = ceil(1.4 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.RESEARCH][BuildingNodeFactory.RESEARCH.UNIVERSITY].researchPerSecond)

func _skill_clean_energy():
	GameState.pollutionMultiplier *= 0.9
	
func _skill_waste_management():
	GameState.pollutionMultiplier *= 0.9
	
func _skill_green_laws():
	GameState.pollutionMultiplier *= 0.8
	GameState.materialMultiplier *= 0.9
	skillDict[SKILLS.FLG_CORRUPTABLE].learned = false
	
func _skill_factory_accountability():
	GameState.pollutionMultiplier *= 0.6
	GameState.materialMultiplier *= 0.5
	
func _skill_reforestation():
	GameState.capacityPerNode *= 1.2
	
func _skill_nature_reserves():
	GameState.capacityPerNode *= 1.5
	GameState.triggerDestruction()
	
func _skill_terraforming():
	GameState.capacityPerNode *= 1.5
	
func _skill_ethical_mining():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].materialsPerSecond = floor(0.7 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].materialsPerSecond)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].footPrint = floor(0.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.MINE].footPrint)
	skillDict[SKILLS.FLG_CORRUPTABLE].learned = false

func _skill_clean_oil():
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].housingCapacity = floor(2.0 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].housingCapacity)
	parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].footPrint = floor(0.5 * parent.buildingNodeFactory.buildingPropertyDict[BuildingNodeFactory.TYPE.PRODUCTION][BuildingNodeFactory.PRODUCTION.REFINERY].footPrint)

func _skill_atomic_energy():
	GameState.pollutionMultiplier *= 0.5

func _skill_cleaner_energy():
	GameState.pollutionMultiplier *= 0.8
	
func _skill_green_zeitgeist():
	GameState.pollutionMultiplier *= 0.8
	skillDict[SKILLS.FLG_CORRUPTABLE].learned = false
	
func _skill_bright_future():
	GameState.pollutionMultiplier = 0
	GameState.notifications.send(Notifications.INDEX.WIN)
	skillDict[SKILLS.FLG_CORRUPTABLE].learned = false
	Audio.playMusic(Audio.MUSIC.BNW)

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
