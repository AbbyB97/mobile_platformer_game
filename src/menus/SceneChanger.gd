extends CanvasLayer

signal scene_changed()

onready var animation_player = $AnimationPlayer
onready var black = $Control/Black

var start_sound = preload("res://src/assets/sfx/menu_select.ogg")
func change_scene(scene_path) -> void :
	var sound_track_player = AudioStreamPlayer.new()
	self.add_child(sound_track_player)
	$AudioStreamPlayer.set_stream(start_sound)
	$AudioStreamPlayer.volume_db=-5
	$AudioStreamPlayer.play()
	$AudioStreamPlayer.set_autoplay(false)
	print("global function called")
	animation_player.play("fade")
	yield(animation_player,"animation_finished")
	get_tree().change_scene(scene_path)
	animation_player.play_backwards("fade")
	yield(animation_player,"animation_finished")
#	yield(sound_track_player,"finished")
	emit_signal("scene_changed")


func _on_AudioStreamPlayer_finished():
	print("menu sound complete")
	$AudioStreamPlayer.stop()
	pass # Replace with function body.
