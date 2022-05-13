extends Actor

# PLAYER VARIABLES ------------------------------------
var max_hp:int = 10
var hp:int = max_hp

var max_ap:int = 5
var ap:int = max_ap

var currentItem:Actor

signal turn_ended
#ANIMATION ---------------------


enum States{
	NO_ITEM,
	WITH_ITEM,
	NOT_TURN
}

var _state:int = States.NO_ITEM
var last_state:int = _state

func _ready() -> void:
	frames = 2
	direction = Vector2.RIGHT
	#connect("turn_ended",get_parent(),"on_player_turn_ended")


func _input(event: InputEvent) -> void:
	
	if _state == States.NOT_TURN:
		return
		
	if tween.is_active():
		return
		
	if event.is_action_pressed("right"):
		ray_scan()
		direction_ray = rayR
		direction = direction_ray.cast_to.normalized()
		check_scanned_tile(direction_ray,direction)
		
	elif event.is_action_pressed("left"):
		ray_scan()
		direction_ray = rayL
		direction = direction_ray.cast_to.normalized()
		check_scanned_tile(direction_ray,direction)
		
	elif event.is_action_pressed("up"):
		ray_scan()
		direction_ray = rayU
		direction = direction_ray.cast_to.normalized()
		check_scanned_tile(direction_ray,direction)
		
	elif event.is_action_pressed("down"):
		ray_scan()
		direction_ray = rayD
		direction = direction_ray.cast_to.normalized()
		check_scanned_tile(direction_ray,direction)
	
	elif event.is_action_pressed("grab"):
		pressed_grab()
		
				
				
		
		

func check_scanned_tile(direction_ray:RayCast2D,direction:Vector2):
	var direction_ray_tile = direction_ray.get_collider()
	match _state:
		States.NO_ITEM:
			if direction_ray_tile == null:
				move(direction)
		States.WITH_ITEM:
			var item_ray_scan_results:Dictionary = currentItem.ray_scan()
			var item_direction_ray:RayCast2D = item_ray_scan_results[direction]
			var item_direction_tile := item_direction_ray.get_collider()
			
#			print(direction_ray_tile)
#			print(item_direction_tile)
			if direction_ray_tile == null:
				if item_direction_tile == null:
					move(direction)
					currentItem.move(direction)
				elif item_direction_tile.is_in_group("walls") or item_direction_tile.is_in_group("items"):
					drop_item()
					move(direction)
				elif item_direction_tile.is_in_group("mobs") and currentItem.is_in_group("swords"):
					attack_mob(item_direction_tile,currentItem)
				
				
					
			
			#moving in dir of item
			if direction_ray_tile == currentItem:
				#empty in front of item
				if item_direction_tile == null or item_direction_tile.is_in_group("door"):
					move(direction)
					currentItem.move(direction)
				elif item_direction_tile.is_in_group("mobs") and currentItem.is_in_group("swords"):
					attack_mob(item_direction_tile,currentItem)
					
			elif  item_direction_tile != null and item_direction_tile.is_in_group("player"):
				if direction_ray_tile == null:
					move(direction)
					currentItem.move(direction)
			
			
			
func move(direction:Vector2):
	match _state:
		States.NO_ITEM:
			move_by_tween(direction)
			animate()
			change_ap(-2)
		States.WITH_ITEM:
			move_by_tween(direction)
			animate()
			change_ap(-3)

func change_ap(ap_diff:int):
	print(ap)
	ap += ap_diff
	if ap <= 0:
		end_turn()
		pass

func change_hp(hp_diff:int):
	hp = max(0,hp + hp_diff)
	if hp == 0:
		die()
	pass

func take_damage(damage:int):
	animPlayer.play('hit')
	change_hp(-damage)

func pressed_grab():
	match _state:
		States.NO_ITEM:
			ray_scan()
			direction_ray = ray_scan_results[direction]
			var direction_ray_tile = direction_ray.get_collider()
	
			if direction_ray_tile != null:
				if direction_ray_tile.is_in_group("items"):
					grab_item(direction_ray_tile)
					
		States.WITH_ITEM:
			drop_item()
			
func grab_item(item:Actor):
	currentItem = item
	_state = States.WITH_ITEM

func drop_item():
	_state = States.NO_ITEM
	currentItem = null
	
func attack_mob(mob:Actor,currentItem:Actor):
	interact_anim(direction)
	print('attack')
	currentItem.interact_anim(direction)
	mob.take_damage(currentItem.attack)
	#yield(mob,"done_taking_damage")
	
	#change_ap(-3)
	pass

func die():
	pass

func start_turn():
	_state = last_state
	ap += max_ap

func end_turn():
	last_state = _state
	_state = States.NOT_TURN
	emit_signal("turn_ended")

func signaled_change_ap():
	change_ap(-3)

func open_door(door,direction):
	interact_anim(direction)
	currentItem.interact_anim(direction)
	door.open()
	var oldItem = currentItem
	drop_item()
	oldItem.opened_door()
	change_ap(-3)
	pass
