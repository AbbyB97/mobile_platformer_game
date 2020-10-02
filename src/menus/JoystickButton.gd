extends TouchScreenButton


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var radius = Vector2(30,30)
var boundry = 60
var ongoing_drag = -1
var return_accel = 20
var threshold = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ongoing_drag==-1:
		var pos_difference = (Vector2(0,0) -radius) - position
		position += pos_difference * return_accel * delta
		
	#print(" == val", get_value())
	if get_value().x > 0  && get_value().y > -0.75  && get_value().y < 0.75:
		Input.action_release("move_left")
		Input.action_press("move_right")
		pass
	#	print(" right", get_value())

	#for using upper drag
	#elif get_value().x < 0  && get_value().y > -0.75  && get_value().y < 0.75:
	
	elif get_value().x < 0  && get_value().y > -0.75  && get_value().y < 0.75:
		Input.action_release("move_right")
		Input.action_press("move_left")
		#print(" right", get_value())
		pass
		
	else:
		#print(" stp", get_value())
		Input.action_release("move_left")
		Input.action_release("move_right")
		Input.action_release("climb")
		Input.action_release("descend")
	
		
		if get_value().y < -0.75:
			#print(" ", get_value())
			Input.action_press("climb")
		
		if get_value().y > 0.75:
			#print(" ", get_value())
			Input.action_press("descend")
	
	
	#old dnt apply
	#if get_value().y < -0.75:
	#	Input.action_press("jump")
	#else:
	#	Input.action_release("jump")
	pass

func get_button_pos():
	return position + radius
	

func _input(event):
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()) :
		var event_dist_from_centre = (event.position - get_parent().global_position).length()
		if event_dist_from_centre <= boundry * global_scale.x or event.get_index()==ongoing_drag:
			
			set_global_position(event.position-radius * global_scale)
			if get_button_pos().length()> boundry:
				set_position(get_button_pos().normalized() * boundry - radius)
			
			ongoing_drag = event.get_index()

	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == ongoing_drag:
		ongoing_drag=-1
		
func get_value():
	if get_button_pos().length() > threshold:
		return get_button_pos().normalized()
	return Vector2(0,0)
