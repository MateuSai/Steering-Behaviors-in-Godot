extends State
class_name WalkState


func enter() -> void:
	state_machine.animation_player.play("walk")
