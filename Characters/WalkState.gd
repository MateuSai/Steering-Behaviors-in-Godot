extends Node
class_name WalkState

const state_name: String = "walk"

onready var state_machine: FSM = get_parent()


func enter_state() -> void:
	state_machine.animation_player.play("walk")
