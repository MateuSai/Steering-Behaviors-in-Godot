extends KinematicBody2D

const WANDER_CIRCLE_RADIUS: int = 8
const WANDER_RANDOMNESS: float = 0.2
var wander_angle: float = 0
export(bool) var wandering: bool = true
export(Rect2) var enclosure_zone: Rect2 = Rect2(16, 16, 480, 256)

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
	
	if wandering:
		steering += enclosure_steering()
		steering += wander_steering()
	else:
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
	
	
func enclosure_steering() -> Vector2:
	var desired_velocity: Vector2 = Vector2.ZERO
	
	if position.x < enclosure_zone.position.x:
		desired_velocity.x += 1
	elif position.x > enclosure_zone.position.x + enclosure_zone.size.x:
		desired_velocity.x -= 1
	if position.y < enclosure_zone.position.y:
		desired_velocity.y += 1
	elif position.y > enclosure_zone.position.y + enclosure_zone.size.y:
		desired_velocity.y -= 1
		
	desired_velocity = desired_velocity.normalized() * max_speed
	if desired_velocity != Vector2.ZERO:
		wander_angle = desired_velocity.angle()
		return desired_velocity - velocity
	else:
		return Vector2.ZERO
	
	
func wander_steering() -> Vector2:
	wander_angle = rand_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	
	var vector_to_cicle: Vector2 = velocity.normalized() * max_speed
	var desired_velocity: Vector2 = vector_to_cicle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	
	return desired_velocity - velocity
