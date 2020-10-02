extends Node2D

func _ready():
	set_camera_limits()
	pass
	
var sound_track= preload("res://src/assets/sfx/sound_track.ogg")

func set_camera_limits():
	var map_limits = $TileMap.get_used_rect()
	var map_cellsize = $TileMap.cell_size
	$Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
	$Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
	$Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
	$Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
	var sound_track_player = AudioStreamPlayer.new()
	self.add_child(sound_track_player)
	sound_track_player.set_stream(sound_track)
	sound_track_player.volume_db=-5
	sound_track_player.play()
