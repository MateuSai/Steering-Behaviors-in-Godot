extends Node
class_name FSM

var state: Node setget set_state
var states: Dictionary = {}

onready var character: KinematicBody2D = get_parent()
onready var animation_player: AnimationPlayer = character.get_node("AnimationPlayer")


func _ready() -> void:
	for child_state in get_children():
		states[child_state.state_name] = child_state
		
	set_state(states.walk)
		
		
func set_state(new_state: Node) -> void:
	state = new_state
	state.enter_state()

