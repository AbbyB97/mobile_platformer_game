extends Button


func _on_StartButton_button_up():

	print("scene changer")
	var next_scene = "res://src/levels/Level01.tscn"
	SceneChanger.change_scene(next_scene)
	print("starting game..")
