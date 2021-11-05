extends KinematicBody2D

var max_speed: int = 70
var max_steering: float = 2.5
var avoid_force: int = 1000

var arrival_zone_radius: int = 20

var velocity: Vector2

onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")
onready var raycasts: Node2D = get_node("Raycasts")


func _process(_delta: float) -> void:
	if velocity.x < -7 and not animated_sprite.flip_h:
		animated_sprite.flip_h = true
	elif velocity.x > 7 and animated_sprite.flip_h:
		animated_sprite.flip_h = false
	
	
func _physics_process(_delta: float) -> void:
	var steering: Vector2 = Vector2.ZERO
	
	var vector_to_target: Vector2 = get_global_mouse_position() - position
	if vector_to_target.length() > arrival_zone_radius:
		steering += seek_steering(vector_to_target)
	else:
		steering += arrival_steering(vector_to_target)
	steering += avoid_obstacles_steering()
	steering = steering.clamped(max_steering)
	
	velocity += steering
	velocity = velocity.clamped(max_speed)
	
	velocity = move_and_slide(velocity)
	
	
func seek_steering(vector_to_target: Vector2) -> Vector2:
	var desired_velocity: Vector2 = vector_to_target.normalized() * max_speed
	
	return desired_velocity - velocity
	
	
func arrival_steering(vector_to_target: Vector2) -> Vector2:
	var speed: float = (vector_to_target.length() / arrival_zone_radius) * max_speed
	var desired_velocity: Vector2 = vector_to_target.normalized() * speed
	
	return desired_velocity - velocity
	
	
func avoid_obstacles_steering() -> Vector2:
	raycasts.rotation = velocity.angle()
	
	for raycast in raycasts.get_children():
		raycast.cast_to.x = velocity.length()
		if raycast.is_colliding():
			var obstacle: PhysicsBody2D = raycast.get_collider()
			return (position + velocity - obstacle.position).normalized() * avoid_force
			
	return Vector2.ZERO
