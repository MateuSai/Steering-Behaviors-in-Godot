extends Node
class_name FSM

var state: Node setget set_state
var states: Dictionary = {}

onready var character: KinematicBody2D = get_parent()
onready var animation_player: AnimationPlayer = character.get_node("AnimationPlayer")


func _ready() -> void:
	for child_state in get_children():
		states[child_state.name.substr(0, name.length() -8).to_lower()] = child_state
		
	set_state(states.idle)
	
	
func _physics_process(_delta: float) -> void:
	var transition: Node = _get_transition()
	if transition != null:
		set_state(transition)
	
	
func _get_transition() -> Node:
	match state:
		states.idle:
			if character.velocity.length() > 5:
				return states.walk
		states.walk:
			if character.velocity.length() < 5:
				return states.idle
				
	return null
		
		
func set_state(new_state: Node) -> void:
	state = new_state
	state.enter()

