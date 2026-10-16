extends CharacterBody2D
class_name Actor 

const speed: = Vector2(300.0, 1000)
const MAX_FALL_SPEED := 400.0 
const gravity: = 50.0
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * gravity * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
	move_and_slide()
	
