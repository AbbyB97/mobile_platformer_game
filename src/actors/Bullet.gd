extends RigidBody2D

export var kunai_speed = 1100

export var kunai_direction :int

onready var kunai_sprite = $Kunai

func _physics_process(delta):
	pass

func _ready():
	if kunai_direction == -1:
		#print("flip ")
		kunai_sprite.set_flip_h(true)
	print("thrown kunai")
	apply_impulse(Vector2(),Vector2(kunai_speed * kunai_direction,0))

func _on_Kunai_body_entered(body):
	#print("kunai impact")
	#set_mode(RigidBody2D.MODE_STATIC)
	set_sleeping(true)
	yield(get_tree().create_timer(0.4),"timeout")
	queue_free()
