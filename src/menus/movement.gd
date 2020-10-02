extends Node2D

func _physics_process(delta):
	get_parent().get_name()
	#print("parent name",get_parent().get_name())
	if get_parent().get_node("Player")!=null:
		var hp = get_parent().get_node("Player").health_points
	#	print("player found")
		$CanvasLayer/Control/Label.set_text(str("health points :",hp))
	
