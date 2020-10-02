extends Actor

func _ready():
	$AnimatedSprite.play("idle")
	$AudioStreamPlayer2D.volume_db=-3
	set_physics_process(false)
	if get_parent().get_node("TileMap")!=null:
		print("tileset found by enemy ")
		var map_limits = get_parent().get_node("TileMap").get_used_rect()
		var map_cellsize = get_parent().get_node("TileMap").cell_size
		bottom_limit = map_limits.end.y * map_cellsize.y
		print("bottom limit for enemy is =",bottom_limit)
	pass

var wall_hit = 0
var direction = -1
var change_direction
var is_attacked = false
var player_in_range = false
var track_player = null


var walk_sound = preload("res://src/assets/sfx/golem_step.wav")
var hurt_sound = preload("res://src/assets/sfx/golem_hurt.wav")
var death_sound = preload("res://src/assets/sfx/golem_death.wav")
var walk_sounded=false
var hurt_sounded=false

var bottom_limit = null

func _physics_process(delta):
	#print("is attacked",is_attacked)
		
	if bottom_limit!=null && position.y>bottom_limit:
		print("enemy dead fall")
		queue_free()
	
	if track_player != null && health_points>0:
		#print(" player post", track_player.get_position())
		#print(" self post", get_position())
		var space_state = get_world_2d().direct_space_state
		var sight_check = space_state.intersect_ray(position,track_player.position,[self],collision_mask)
		#print("collider ",sight_check)
		if sight_check.has('collider'):
			if sight_check.collider.name=="Player":
				follow_player()
		pass
	if is_on_wall() && is_attacked==false && player_in_range==false :
		direction = - direction
		wall_hit = wall_hit + 1
		#print("wall hit", wall_hit)
	
	if player_in_range==true && is_attacked==false:
		$AnimatedSprite.play("attack")
	
	if$AnimatedSprite.animation=="attack" && $AnimatedSprite.frame>4:
		#print("player hit success")
		$EnemyAttack/CollisionShape2D.disabled=false
		$EnemyAttack2/CollisionShape2D.disabled=false
	else:
		$EnemyAttack/CollisionShape2D.disabled=true
		$EnemyAttack2/CollisionShape2D.disabled=true
	
	if direction == -1:
		$AnimatedSprite.flip_h=true
	else: 
		$AnimatedSprite.flip_h=false
	
	if is_attacked==false && player_in_range==false:
		velocity.x= speed.x * direction
	
	if wall_hit == 3 && track_player == null:
		#print("wait")
		velocity.x=0
		play_animation()
		yield(get_tree().create_timer(3.0),"timeout")
		wall_hit=0
		
	play_animation()
	
	pass

func follow_player():
	if track_player!=null:
		direction = -1 if track_player.get_position().x < get_position().x else 1

func play_animation():
	if velocity.x!=0:
		$AnimatedSprite.play("walking")
		if walk_sounded==false:
			$AudioStreamPlayer2D.set_stream(walk_sound)
			$AudioStreamPlayer2D.play()
			walk_sounded=true
	if velocity.x==0 && is_attacked==false && player_in_range==false:
		#print("idle")
		$AnimatedSprite.play("idle")
	pass

func _on_Golem01MidArea_area_entered(area):
	#print(" entered name  ",area.get_name())
	if area.is_in_group("player_attack") && health_points>0:
		velocity.x=0
		is_attacked = true
		print("entered area post", area.get_position())
		walk_sounded=false
		if $AnimatedSprite.animation!="hurt":
			$AnimatedSprite.play("hurt")
		if hurt_sounded==false:
			$AudioStreamPlayer2D.set_stream(hurt_sound)
			$AudioStreamPlayer2D.play()
			hurt_sounded=true
		if area.get_position().x > 0:
			change_direction =  -1
		else:
			change_direction = 1
		health_points -=1
		print("health", health_points)
		if health_points==0:
			$AnimatedSprite.play("dying")
			$AudioStreamPlayer2D.set_stream(death_sound)
			$AudioStreamPlayer2D.play()
			
	pass # Replace with function body.



func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "hurt":
		is_attacked=false
		direction= change_direction
		
	if $AnimatedSprite.animation=="dying":
		$AnimatedSprite.set_frame(14)
		$AnimatedSprite.stop()
		$Golem01MidArea_Enemy/CollisionShape2D.disabled=true
		yield(get_tree().create_timer(0.6),"timeout")
		queue_free()
			
	pass # Replace with function body.


func _on_MeleeRangeL_body_entered(body):
	#print("enemy melee range body entered",body.get_name())
	if body.get_name()== "Player" && health_points>0:
		player_in_range=true
		velocity.x=0
		$AnimatedSprite.play("attack")
	pass # Replace with function body.

func _on_MeleeRangeL_body_exited(body):
	#print("enemy melee range body exited",body.get_name())
	if body.get_name()== "Player":
		player_in_range=false
	pass # Replace with function body.

func _on_PlayerDetect_body_entered(body):
	if body.get_name()== "Player":
		#print("player position", body.get_position())
		#print("self position", get_position())
		track_player = body
	pass # Replace with function body.


func _on_PlayerDetect_body_exited(body):
	if body.get_name()== "Player":
		#print("player position", body.get_position())
		#print("self position", get_position())
		track_player = null
	pass # Replace with function body.


func _on_AudioStreamPlayer2D_finished():
	if $AudioStreamPlayer2D.stream.resource_path=="res://src/assets/sfx/golem_step.wav":
		$AudioStreamPlayer2D.stop()
		walk_sounded=false
		hurt_sounded=false
	if $AudioStreamPlayer2D.stream.resource_path=="res://src/assets/sfx/golem_hurt.wav":
		$AudioStreamPlayer2D.stop()
		walk_sounded=false
		hurt_sounded=false
		
	pass # Replace with function body.


func _on_Golem01MidArea_Enemy_area_exited(area):
	if area.is_in_group("player_attack") && health_points>0:
#		is_attacked=false
		follow_player()
		#velocity.x = speed.x * direction
	pass # Replace with function body.
