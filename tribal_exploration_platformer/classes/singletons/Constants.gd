extends Node

var PHYSICS:__PHYSICS = __PHYSICS.new()
var COLLISION:__COLLISION = __COLLISION.new()

class __PHYSICS:
	var GRAVITY:Vector2 = ProjectSettings.get_setting("physics/2d/default_gravity_vector") * ProjectSettings.get_setting("physics/2d/default_gravity")
	
class __COLLISION:
	const SOLID:int = 0
	const ACTOR:int = 1
	const PLAYER:int = 2
	const ENEMY:int = 3
	const GAME_OBJECT:int = 7
