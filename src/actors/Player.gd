extends Actor

var is_grounded 
signal grounded_updated(is_grounded)

func _physics_process(delta):
	if is_sliding==true:
		$CollisionShape2D2.set_disabled(false)
		$CollisionShape2D.set_disabled(true)
		$AnimatedSprite.set_offset(Vector2(0,75))
	else:
		$CollisionShape2D2.set_disabled(true)
		$CollisionShape2D.set_disabled(false)
		$AnimatedSprite.set_offset(Vector2(0,10))
		
	
	movementAndAnmiation()
	
	var was_grounded = is_grounded
	is_grounded = is_on_floor()
	if was_grounded == null || is_grounded!= was_grounded:
		emit_signal("grounded_updated",is_grounded)
	
	update_melee_range()
	
	
func update_melee_range():
	if ($AnimatedSprite.animation == "melee_attack" 
	 || $AnimatedSprite.animation == "jump_attack" ) && $AnimatedSprite.frame>3:
		if $AnimatedSprite.flip_h == false:
			$MeleeRangeL/CollisionShape2D.disabled = false
		else:
			$MeleeRangeR/CollisionShape2D.disabled = false
	pass

var bottom_limit = null
func _ready():
	#$AnimatedSprite.play("idle")
	$MeleeRangeL/CollisionShape2D.disabled=true
	$AudioStreamPlayer.volume_db=-3
	if get_parent().get_node("TileMap")!=null:
	#	print("tileset found")
		var map_limits = get_parent().get_node("TileMap").get_used_rect()
		var map_cellsize = get_parent().get_node("TileMap").cell_size
		bottom_limit = map_limits.end.y * map_cellsize.y
#		print("bottom limit is =",bottom_limit)
	pass


var kunai = preload("res://src/actors/Bullet.tscn")
var kunai_sound = preload("res://src/assets/sfx/throw.wav")
var sword_slash_sound = preload("res://src/assets/sfx/slash.wav")
var run_sound = preload("res://src/assets/sfx/steps_platform.ogg")
var slide_sound = preload("res://src/assets/sfx/slide_sound.wav")
var jump_sound = preload("res://src/assets/sfx/jump.wav")
var player_hurt_sound = preload("res://src/assets/sfx/player_hurt.wav")
var player_dead_sound = preload("res://src/assets/sfx/player_death.wav")
var hurt_voiced = false
var jump_voiced = false
var slash_sounded = false
#for playing shoot kunai anim
var can_throw = true
var throw_rate = 0.5
var is_climbing = false
var is_climb_region = false
var ladder_jump = false
#movement flags 
var left_right_movement = 0
var is_attacking = false #jump only once , true when jumped false when hits ground
var is_sliding = false
var is_hurt = false


func movementAndAnmiation():
	
	#print("hp = ",health_points)
	
	if bottom_limit!=null && position.y>bottom_limit:
		#print("player dead fall")
		set_process(false)
		var next_scene = "res://src/menus/GameOver.tscn"
		SceneChanger.change_scene(next_scene)
	
	if health_points==0:
		velocity=Vector2(0,0)
		#print("dead")
		if $AnimatedSprite.animation != "dead" && $AudioStreamPlayer.stream.resource_path!="res://src/assets/sfx/player_death.wav":
			$AnimatedSprite.play("dead")
			$AudioStreamPlayer.set_stream(player_dead_sound)
			$AudioStreamPlayer.play()
		yield(get_tree().create_timer(2.0),"timeout")
		set_process(false)
		var next_scene = "res://src/menus/GameOver.tscn"
		SceneChanger.change_scene(next_scene)
		#queue_free()
	
	
	if is_on_floor():
		left_right_movement = 0
		if $AnimatedSprite.animation == "jump_ranged_attack" :
			is_attacking=false
			is_sliding = false
	
	if Input.get_action_strength("climb")==1 && is_climb_region==true:
		gravity=0
		velocity.y= -300
		is_climbing = true
		#print("climb")
		$AnimatedSprite.play("climb")
		
	if Input.get_action_strength("descend")==1 && is_climb_region==true && is_climbing==true:
		gravity=0
		velocity.y= +300
		$AnimatedSprite.play("climb",true)
		
		#print("climb")
		
	if (Input.get_action_strength("climb")==0 
		&& Input.get_action_strength("descend")==0 
		&& is_climb_region==true && is_climbing==true):
		velocity.y= 0
		$AnimatedSprite.stop()
		
		
	if (Input.is_action_pressed("jump") && is_on_floor() 
		#to make sure attack is not pressed
		&& Input.is_action_pressed("glide")==false
		&& Input.get_action_strength("melee_attack")==0 
		&& is_sliding==false
		&& Input.get_action_strength("ranged_attack")==0 && is_attacking==false):
		#print("jump  pressed")
		velocity.y = -speed.y
	#print(" vel x", speed.x * left_right_movement)
	
	if (Input.get_action_strength("melee_attack")==0 
		&& Input.get_action_strength("ranged_attack")==0  
		#to make sure attack is not pressed	
		#&& is_sliding == false
		&& is_hurt==false
		&& is_attacking==false):
		left_right_movement = Input.get_action_strength("move_right")-Input.get_action_strength("move_left")
	
	if is_sliding == false :
		velocity.x= speed.x * left_right_movement
	else :
		if $AnimatedSprite.flip_h == true:
			velocity.x= speed.x * -1
		else:
			velocity.x= speed.x * 1
			

	if velocity.y != 0:
		is_attacking=false
		is_sliding = false
		
		if Input.is_action_pressed("glide"):
			$AnimatedSprite.play("glide")
			velocity.y= speed.y - 900
		
		if ((Input.is_action_just_pressed("melee_attack")
			|| Input.is_action_just_pressed("ranged_attack"))
			&& Input.is_action_pressed("glide")==false):
			#print("air attack")
			if Input.is_action_just_pressed("melee_attack") :
				$AnimatedSprite.play("jump_attack")
			else :
				if can_throw == true:
					can_throw = false
					$AnimatedSprite.play("jump_ranged_attack")
					var kunai_instance = kunai.instance() 
					kunai_instance.position = get_global_position()
					if $AnimatedSprite.flip_h==true:
						#print("flip yes")
						
						kunai_instance.kunai_direction= -1
					else:
						#print("flip no")
						kunai_instance.kunai_direction= 1
					get_parent().add_child(kunai_instance)
					$AudioStreamPlayer.set_stream(kunai_sound)
					$AudioStreamPlayer.play()
					yield(get_tree().create_timer(throw_rate),"timeout")
					can_throw = true
				yield($AnimatedSprite,"animation_finished")

		else:
			if ($AnimatedSprite.animation!= "jump_attack" && $AnimatedSprite.animation!= 
				"jump_ranged_attack" && $AnimatedSprite.animation!= "glide" 
				&& is_climbing==false):
				$AnimatedSprite.play("jump")

		
	
	if velocity.x < 0:
		#print("velocity.x ",velocity.x)
		$AnimatedSprite.flip_h = true
		if is_on_floor():
			if Input.is_action_pressed("slide") && $AnimatedSprite.animation=="run" && $AnimatedSprite.frame > 3:
				is_sliding = true
				$AnimatedSprite.play("slide")
				$AudioStreamPlayer.set_stream(slide_sound)
				$AudioStreamPlayer.play()
			elif is_sliding==false:
				$AnimatedSprite.play("run")
				$MeleeRangeL/CollisionShape2D.disabled=true
				$MeleeRangeR/CollisionShape2D.disabled=true
	
				
			is_attacking=false
	elif velocity.x>0:
		#print("velocity.x ",velocity.x)
		$AnimatedSprite.flip_h = false
		if is_on_floor():
			if Input.is_action_pressed("slide") && $AnimatedSprite.animation=="run" && $AnimatedSprite.frame > 3:
				is_sliding = true
				$AnimatedSprite.play("slide")
				$AudioStreamPlayer.set_stream(slide_sound)
				$AudioStreamPlayer.play()
			elif is_sliding==false:
				$AnimatedSprite.play("run")
				$MeleeRangeL/CollisionShape2D.disabled=true
				$MeleeRangeR/CollisionShape2D.disabled=true
	
			is_attacking=false
			
	
	if (Input.get_action_strength("melee_attack")==1
		&& slash_sounded==false
		):
		$AudioStreamPlayer.set_stream(sword_slash_sound)
		$AudioStreamPlayer.play()
		slash_sounded=true
		#$AudioStreamPlayer.set_autoplay(true)
	if (velocity.x!=0
		&& $AudioStreamPlayer.is_playing()==false
		&& is_on_floor()
		):
		$AudioStreamPlayer.set_stream(run_sound)
		$AudioStreamPlayer.play()
		#$AudioStreamPlayer.set_autoplay(true)
	elif $AnimatedSprite.animation=="jump" && jump_voiced==false && $AnimatedSprite.frame==0: 
		$AudioStreamPlayer.set_stream(jump_sound)
		$AudioStreamPlayer.play()
		$AudioStreamPlayer.set_autoplay(true)
		jump_voiced=true
		
	else:
		if((velocity.x==0 || is_on_floor()==false) 
	&& $AnimatedSprite.animation!="melee_attack" 
	&& $AnimatedSprite.animation!="ranged_attack"
	&& $AnimatedSprite.animation!="jump_ranged_attack"
	&& $AnimatedSprite.animation!="jump_attack"
	&& $AnimatedSprite.animation!="slide"
	&& $AnimatedSprite.animation!="jump"
	&& $AnimatedSprite.animation!="hurt"
	): 
			$AudioStreamPlayer.stop()

			
	if velocity.x==0  && is_on_floor():
		if Input.is_action_pressed("melee_attack"):
			is_attacking=true
			#print("melee attack")
			$AnimatedSprite.play("melee_attack")

		elif Input.is_action_pressed("ranged_attack"):
			is_attacking=true
			#print("ranged attack")
			
			if can_throw == true:
				can_throw = false
				$AnimatedSprite.play("ranged_attack")
				$AudioStreamPlayer.set_stream(kunai_sound)
				$AudioStreamPlayer.play()
				
				var kunai_instance = kunai.instance() 
				kunai_instance.position = get_global_position()
				if $AnimatedSprite.flip_h==true:
				#	print("flip yes")
					
					kunai_instance.kunai_direction= -1
				else:
				#	print("flip no")
					kunai_instance.kunai_direction= 1
				get_parent().add_child(kunai_instance)
				yield(get_tree().create_timer(throw_rate),"timeout")
				can_throw = true
			yield($AnimatedSprite,"animation_finished")

		else:
			#print("stay idle ")
			if is_attacking == false && is_sliding==false:
				if is_hurt == true && health_points>0:
					$AnimatedSprite.play("hurt")
					if hurt_voiced==false:
						$AudioStreamPlayer.set_stream(player_hurt_sound)
						$AudioStreamPlayer.play()
						hurt_voiced=true
				else:
					if health_points > 0:
						$AnimatedSprite.play("idle")
				$MeleeRangeL/CollisionShape2D.disabled=true
				$MeleeRangeR/CollisionShape2D.disabled=true
	
	if is_on_floor() == true && is_climb_region==true:
#		print("on floor")
#		print("is_climbing ",is_climbing)
		is_climbing=false
#		print("isplaying ",$AnimatedSprite.is_playing())
#		print(" vel ",velocity)
#		print(" ladder_jump ",ladder_jump)
		gravity = 4000.0
		velocity.y += gravity * get_process_delta_time()
		Input.action_release("climb")
		Input.action_release("descend")
		
		#$AnimatedSprite.play("idle")
		#else:
		#	$AnimatedSprite.play("idle")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "melee_attack" || $AnimatedSprite.animation == "ranged_attack":
		is_attacking=false
		is_sliding = false
		$MeleeRangeL/CollisionShape2D.disabled=true
		$MeleeRangeR/CollisionShape2D.disabled=true
		
	if $AnimatedSprite.animation=="jump":
		$AnimatedSprite.set_frame(9)
	
	if $AnimatedSprite.animation=="slide":
		#velocity.x=0
		Input.action_release("slide")
		is_sliding = false
		#$AnimatedSprite.play("run")
	if	$AnimatedSprite.animation=="jump_attack":
		$MeleeRangeL/CollisionShape2D.disabled=true
		$MeleeRangeR/CollisionShape2D.disabled=true
		$AnimatedSprite.stop()
		$AnimatedSprite.animation="jump"
		$AnimatedSprite.set_frame(9)
		
	
	if	$AnimatedSprite.animation=="jump_ranged_attack":
		is_attacking=false
		is_sliding = false
		$AnimatedSprite.stop()
		$AnimatedSprite.animation="jump"
		$AnimatedSprite.set_frame(9)
	
	if	$AnimatedSprite.animation=="glide" && Input.is_action_pressed("glide")==false:
		$AnimatedSprite.stop()
		$AnimatedSprite.animation="jump"
		$AnimatedSprite.set_frame(9)
	
	if $AnimatedSprite.animation == "hurt":
		is_hurt=false
	
	if $AnimatedSprite.animation == "dead":
		$AnimatedSprite.set_frame(9)
		#set_visible(false)
	
	
	pass 


func _on_PlayerMidArea_area_entered(area):
#	print("area mid entered detected ",area.get_name())
	if "ClimbRegion" in area.get_name():
		is_climb_region=true
#		print("climb_region - ",is_climb_region)
	
	if "Area_Enemy" in area.get_name() && get_position().y > area.get_position().y:
		#print("player pos",get_position().y)
		#print("area pos",area.get_position().y)
		#print("jump")
		velocity.y=-speed.y
	
	if "EnemyAttack" in area.get_name() && health_points>0:
		is_hurt=true
		health_points =health_points- 1 
		
		#print("enemy attacked player")
	pass # Replace with function body.


func _on_PlayerMidArea_area_exited(area):
	if "ClimbRegion" in area.get_name():
		is_climb_region=false
		is_climbing = false
		gravity = 4000.0
		velocity.y += gravity * get_process_delta_time()
		Input.action_release("climb")
		Input.action_release("descend")
		if ladder_jump==true:
			velocity.y= -speed.y
			ladder_jump=false
	#	print("climb_region - ",is_climb_region)
	if "ClimbJumpPad" in area.get_name():
#		print("enable ladder jump")
#		print(" area pos ",area.get_position().y)
#		print(" player pos ",get_position().y)
		if get_position().y < area.get_position().y:
			ladder_jump=true
		else:
			ladder_jump= false
	if "EnemyAttack" in area.get_name() && health_points>0 :
		is_hurt=false
#		print("player exited attacked region")
	#print(" animation scale speed",$AnimatedSprite.speed_scale)
	pass # Replace with function body.


func _on_AudioStreamPlayer_finished():
	#print("rsc pt",$AudioStreamPlayer.stream.resource_path)
	if $AudioStreamPlayer.stream.resource_path=="res://src/assets/sfx/jump.wav":
		$AudioStreamPlayer.stop()
		slash_sounded=false
		jump_voiced=false
		hurt_voiced=false
		
	if $AudioStreamPlayer.stream.resource_path=="res://src/assets/sfx/slash.wav":
		$AudioStreamPlayer.stop()
		slash_sounded=false
		jump_voiced=false
		hurt_voiced=false
	if $AudioStreamPlayer.stream.resource_path=="res://src/assets/sfx/throw.wav":
		$AudioStreamPlayer.stop()
		slash_sounded=false
		jump_voiced=false
		hurt_voiced=false
	if $AudioStreamPlayer.stream.resource_path=="res://src/assets/sfx/player_hurt.wav":
		$AudioStreamPlayer.stop()
		slash_sounded=false
		jump_voiced=false
		hurt_voiced=false
	pass # Replace with function body.
