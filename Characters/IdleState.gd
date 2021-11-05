extends State
class_name IdleState


func enter() -> void:
	state_machine.animation_player.play("idle")

