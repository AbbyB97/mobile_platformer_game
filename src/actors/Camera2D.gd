extends Camera2D



const SHIFT_TRANS = Tween.TRANS_SINE
const SHIFT_EASE = Tween.EASE_OUT
const SHIFT_DURATION = 1.0


const LOOK_AHEAD_FACTOR = 0.8

onready var prev_camera_pos = get_camera_position()
onready var tween = $ShiftTween

var facing = 0
func _process(delta):
	_check_facing()
	prev_camera_pos=get_camera_position()

func _check_facing():
	var new_facing = sign (get_camera_position().x-prev_camera_pos.x)
	if new_facing != 0 && facing != new_facing:
		facing = new_facing
		var target_offset = get_viewport_rect().size.x * LOOK_AHEAD_FACTOR * facing
	#	position.x = target_offset
		tween.interpolate_property(self,"position:x",position.x,target_offset,SHIFT_DURATION,SHIFT_TRANS,SHIFT_EASE)
		tween.start()
		
	
func _on_Player_grounded_updated(is_grounded):
	#print("camera update")
	drag_margin_v_enabled = !is_grounded
	pass # Replace with function body.
