extends Actor

# MOB VARIABLES ---------------------------
var max_hp := 6
var hp := max_hp

var max_ap := 1
var ap = max_ap

var damage := 3
enum States {
	FINDING_PLAYER,
	FOUND_PLAYER
}
var vector_to_player:Vector2
onready var playerDetectorRay = $PlayerDetectorRay
signal turn_ended(mob)
signal done_scanning
signal local_done_turn
var _state = States.FINDING_PLAYER

func change_hp(hp_diff):
	hp = max(0, hp + hp_diff)
	if hp == 0:
		die()
	

func _ready() -> void:
	frames = 2
	

func act():
	while ap > 0:
		print('ap != 0')
		ray_scan()
		look_for_player()
		yield(self,"done_scanning")
		
		
		match _state:
			States.FINDING_PLAYER:
				act_find_player()
				pass
			States.FOUND_PLAYER:
				act_found_player()
				pass
		
		animate()
		ap -= 1
		
		
	print('out of loop')
	end_turn()
	
			
			
	

func take_damage(damage:int):
	animPlayer.play('hit')
	change_hp(-damage)


func die():
	queue_free()

func act_find_player():
	#scan rays, store empty ones in an array
	#if array is empty, skip turn
	#if any of them find the player, attack the player
	#pick a random direction to move in from the array
	#move
	
	var empty_directions:Array
	for ray in ray_scan_results.keys():
		if ray_scan_results[ray].get_collider() == null:
			empty_directions.append(ray)
	#if no open spots
	if empty_directions.size() >= 1:
		var rng_direction = empty_directions[randi() % empty_directions.size()]
		move_by_tween(rng_direction)
	
	
func attack_player():
	pass	
	
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
	move_by_tween(larger_value)
		
		
func look_for_player():
	var found_player = false
	var foundRay:RayCast2D
	playerDetectorRay.rotation_degrees = 0
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
			
	if found_player:
		pass
	else:
		ray_no_detect_player()
	
	emit_signal("done_scanning")
	
	

func ray_detected_player(foundRay):
	print(foundRay.cast_to)
	vector_to_player = foundRay.cast_to.normalized()
	_state = States.FOUND_PLAYER
	#normalize it
	#see if the x or y is bigger
	# go in that direction
	pass

func ray_no_detect_player():
	_state = States.FINDING_PLAYER

func end_turn():
	print('turn ended')
	emit_signal("turn_ended",self)
	ap = max_ap
	pass
