extends Area2D



func _on_SaveCamp_body_entered(body):
	if body.name=="Player":
		print("scene changer")
		var next_scene = "res://src/menus/LevelComplete.tscn"
		SceneChanger.change_scene(next_scene)

	pass # Replace with function body.
