extends KinematicBody2D
class_name Actor

export var speed  = Vector2(300.0,1000.0)
export var gravity = 4000.0
export var health_points:int = 3

var velocity: = Vector2.ZERO
const FLOOR_NORMAL = Vector2.UP

func _physics_process(delta):
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity,FLOOR_NORMAL)
