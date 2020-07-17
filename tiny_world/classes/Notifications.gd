extends Node
class_name Notifications

enum INDEX {
	WELCOME, QUAKE_TUTORIAL, CHAIN_REACTION, TAUNT, GAME_OVER, WIN
}

var notifDict = {
	INDEX.WELCOME: Notification.new("Hello and Welcome to your new, personal Planet!\n\nPopulate your new world by providing Housing for people.\nTo extract wealth, build Production lines.\nSince it's always important to stay ahead, building Research facilities is adviced to buy Upgrades and new building types.\n\nSince material is useless without labor and research won't get done on its own, People are required for both. Change the slider below the population count to change what the people value more; wealth or knowledge. They will fill the facilities capacity accordingly.\n\nWe hope to see your world prosper in your hands. Don't disappoint us."),
	INDEX.QUAKE_TUTORIAL: Notification.new("It has come to our attention that your World just was victim of natural disaster. I hope you kept in mind, that rapid growth can destabilise the eco system, which could make vast land masses inhospitable.\n\nBe advised, that this process is irreversible and might lead to a chain reaction.\n\nAs a sign of good will, we have unlocked research into disaster prevention.\n\nDon't let this happen again."),
	INDEX.CHAIN_REACTION: Notification.new("Maybe the urgentness of the situation in our last message wasn't clear enough. The reduction of your personal planet is cause for concern.\nFurther loss of inhabitable land could lead to chain reactions in multiple environmental factors, which may progress faster than you can manage.\n\nWe advice to invest more into sustainable options."),
	INDEX.TAUNT: Notification.new("To circle back to our last statement: Planet shrink bad. Resolve this issue at once or your world will be nothing more than a spec of dust."),
	INDEX.GAME_OVER: Notification.new("Dear lady, gentleman or distinguished person outside the binary,\n\nWe regret to inform you, that you now see the last breaths of a once prosperous and promising new planet. The destruction of this world under your responsibility is imminent and unstoppable.\n\nWe want to remind you, that this is all your fault.\n\nBest regards"),
	INDEX.WIN: Notification.new("Congratulations.\nYou successfully created a society where the smartest of the smarties could develop a solution to the greatest threat of your world. Consider your journey a complete success. Feel free to continue building your own world, but as far as we are concerned, you won.")
}

var parent

func _init(_parent):
	self.parent = _parent
	
func send(_notificationId:int):
	var _notif = notifDict.get(_notificationId)
	if _notif == null or (_notif.once and _notif.send):
		return
	_notif.send = true
	self.parent.emit_signal("notification", _notif.text)

class Notification:
	var text:String = ""
	var once:bool = false
	var send:bool = false
	
	func _init(_text, _once = true):
		text = _text
		once = _once 
