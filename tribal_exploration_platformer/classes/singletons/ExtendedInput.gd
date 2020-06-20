extends Node

const BUFFER_LENGTH = 0.2
var buffer:Buffer = Buffer.new(self, BUFFER_LENGTH)

func _input(_event:InputEvent):
	if _event.is_action_pressed("act_jump"):
		buffer.insert("act_jump")

func getInputVector() -> Vector2:
	return Vector2(
		Input.get_action_strength("mov_right") - Input.get_action_strength("mov_left"),
		Input.get_action_strength("mov_down") - Input.get_action_strength("mov_up"))

func is_action_just_pressed(_action:String) -> bool:
	return buffer.consume(_action) or Input.is_action_just_pressed(_action)

func is_action_pressed(_action:String) -> bool:
	return Input.is_action_pressed(_action)

func is_action_just_released(_action:String) -> bool:
	return buffer.consume("released_" + _action) or Input.is_action_just_released(_action)
