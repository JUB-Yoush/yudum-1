extends Actor

# PLAYER VARIABLES ------------------------------------
var max_hp:int = 10
var hp:int = max_hp

var max_ap:int = 6
var ap:int = max_ap

var currentItem:Actor

#var item_ray_scan_results:Dictionary = {
#	Vector2.RIGHT:null,
#	Vector2.LEFT:null,
#	Vector2.UP:null,
#	Vector2.DOWN:null
#}

#ANIMATION ---------------------


enum States{
	NO_ITEM
	WITH_ITEM
}

var _state:int = States.NO_ITEM

func _ready() -> void:
	frames = 2
	direction = Vector2.RIGHT


func _unhandled_input(event: InputEvent) -> void:
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
			var item_direction_tile = item_direction_ray.get_collider()
			
#			print(direction_ray_tile)
#			print(item_direction_tile)
			if direction_ray_tile == null:
				if item_direction_tile == null:
					move(direction)
					currentItem.move(direction)
				elif item_direction_tile.is_in_group("walls") or item_direction_tile.is_in_group("items"):
					drop_item()
					move(direction)
				elif item_direction_tile.is_in_group("mob"):
					attack_mob(item_direction_tile,currentItem)
				
					
			
			#moving in dir of item
			if direction_ray_tile == currentItem:
				#empty in front of item
				if item_direction_tile == null:
					move(direction)
					currentItem.move(direction)
				elif item_direction_tile.is_in_group("mobs"):
					attack_mob(item_direction_tile,currentItem)
					
			if  item_direction_tile != null and item_direction_tile.is_in_group("player"):
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
	ap += ap_diff
	if ap <= 0:
		pass

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
	mob.take_damage(currentItem.attack)
	pass
