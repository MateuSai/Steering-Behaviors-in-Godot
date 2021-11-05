extends TextureRect


func _input(_event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_D):
		show()

