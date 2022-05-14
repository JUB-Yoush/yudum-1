extends Actor

# MOB VARIABLES ---------------------------
var max_hp := 6
var hp := max_hp

var max_ap := 1
var ap = max_ap
var just_found_player = false

# SFX ------------------------------------
var hit_sfx  := load("res://assets/sounds/hit.wav")
var found_sfx  := load("res://assets/sounds/mob_found_player.wav")
var walk_sfx  := load("res://assets/sounds/mob_walk.wav")
var die_sfx  := load("res://assets/sounds/mob_die_new.wav")

onready var audio = $AudioStreamPlayer

var damage := 1
var alive = true
export var drops_key = false
enum States {
	FINDING_PLAYER,
	FOUND_PLAYER
}
var found_colour := "F53A29"
var finding_colour := "F1A208"

var vector_to_player:Vector2
onready var playerDetectorRay = $PlayerDetectorRay
signal turn_ended(mob)
signal done_scanning
signal local_done_turn
signal done_taking_damage
var _state = States.FINDING_PLAYER

func change_hp(hp_diff):
	hp = max(0, hp + hp_diff)
	if hp == 0:
		die()
	print("done taking damage")
	get_parent().get_node("Player").change_ap(-3)
	

func _ready() -> void:
	frames = 2
	

func act():
	while ap > 0:
		ray_scan()
		look_for_player()
		yield(self,"done_scanning")
		if alive == false:
			if drops_key:
				get_parent().make_key(position)
			queue_free()
		
		match _state:
			States.FINDING_PLAYER:
				sprite.modulate = finding_colour
				act_find_player()
				pass
			States.FOUND_PLAYER:
				sprite.modulate = found_colour
				act_found_player()
				pass
		
		animate()
		ap -= 1
		
		
	end_turn()
	
			
			
	

func take_damage(damage:int):
	animPlayer.play('hit')
	change_hp(-damage)
	play_sfx(hit_sfx)


func die():
	print('died')
	alive = false
	get_parent().play_sfx(die_sfx)
	hide()
	

func act_find_player():
	var empty_directions:Array
	for ray in ray_scan_results.keys():
		if ray_scan_results[ray].get_collider() == null:
			empty_directions.append(ray)
	#if no open spots
	if empty_directions.size() >= 1:
		var rng_direction = empty_directions[randi() % empty_directions.size()]
		move_by_tween(rng_direction)
		play_sfx(walk_sfx)
	
	
func attack_player(player,direction):
	interact_anim(direction)
	player.take_damage(damage)
	
func act_found_player():
	var p_vector_x = vector_to_player.x
	var p_vector_y = vector_to_player.x
	var larger_value:Vector2
	
	if abs(vector_to_player.x) > abs(vector_to_player.y):
		larger_value = Vector2.RIGHT * sign(vector_to_player.x)
	elif abs(vector_to_player.x) < abs(vector_to_player.y):
		larger_value = Vector2.DOWN * sign(vector_to_player.y)
	elif abs(vector_to_player.x) == abs(vector_to_player.y):
		larger_value = Vector2.RIGHT * sign(vector_to_player.x)
	
	var found_player = false
	ray_scan()
	for ray in ray_scan_results.keys():
		if ray_scan_results[ray].get_collider() != null:
			print(ray_scan_results[ray].get_collider())
		if ray_scan_results[ray].get_collider() != null and ray_scan_results[ray].get_collider().is_in_group("player"):
			print('got player')
			found_player == true
			attack_player(ray_scan_results[ray].get_collider(),ray)
			
	if !found_player:
		move_by_tween(larger_value)
		play_sfx(walk_sfx)
		
		
		
		
func look_for_player():
	var found_player = false
	var foundRay:RayCast2D
	playerDetectorRay.rotation_degrees = 0
	#var all_items = get_tree().get_nodes_in_group("items")
#	for item in all_items:
#		item.collision_layer = 4
		
	for i in range(360/15):
		playerDetectorRay.cast_to = Vector2(64,0).rotated(deg2rad(15 * i))
		yield(get_tree().create_timer(0.00001), "timeout")
		playerDetectorRay.force_raycast_update()
#		if playerDetectorRay.get_collider() != null:
#			print(playerDetectorRay.get_collider().get_groups())
		if playerDetectorRay.get_collider() != null and playerDetectorRay.get_collider().is_in_group("player") and found_player == false:
			found_player = true
			foundRay = playerDetectorRay
			ray_detected_player(foundRay)
	
#	for item in all_items:
#		item.collision_layer = 1
		
	if found_player:
		pass
	else:
		ray_no_detect_player()
		
	emit_signal("done_scanning")
	
	

func ray_detected_player(foundRay):
	if just_found_player == false:
		just_found_player = true
		play_sfx(found_sfx)
		
	print(foundRay.cast_to)
	vector_to_player = foundRay.cast_to.normalized()
	_state = States.FOUND_PLAYER
	#normalize it
	#see if the x or y is bigger
	# go in that direction
	pass

func ray_no_detect_player():
	just_found_player = false
	_state = States.FINDING_PLAYER

func end_turn():
	emit_signal("turn_ended",self)
	ap = max_ap
	pass

func play_sfx(sfx):
	audio.set_stream(sfx)
	audio.play()
