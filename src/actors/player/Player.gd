extends Actor

# PLAYER VARIABLES ------------------------------------
var max_hp:int = 3
var hp:int = max_hp

var max_ap:int = 5
var ap:int = max_ap

var currentItem:Actor
var stage = 1
signal turn_ended
#ANIMATION ---------------------
var noitem_colour = "fcbfb7"
var item_colour = "C1D7AE"
onready var ui = $UI
onready var audio := $AudioStreamPlayer

# SOUND EFFECTS -------------------------------
var walking_sfx= load("res://assets/sounds/player_walk.wav")
var hit_sfx  := load("res://assets/sounds/hit.wav")
var open_door_sfx  := load("res://assets/sounds/open_door.wav")
var grab_item_sfx  := load("res://assets/sounds/grab_item.wav")
var drop_item_sfx  := load("res://assets/sounds/drop_item.wav")
var next_floor_sfx := load("res://assets/sounds/next_level.wav")




enum States{
	NO_ITEM,
	WITH_ITEM,
	NOT_TURN
}

var idle_anim = [0,1]
var push_anim = [2,3]
var current_anim:Array

var _state:int = States.NO_ITEM
var last_state:int = _state

func _ready() -> void:
	play_sfx(next_floor_sfx)
	frames = 2
	direction = Vector2.RIGHT
	ui.update_hp_label(hp)
	ui.update_ap_label(ap)
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
	elif event.is_action_pressed("pass"):
		pass_ap()
				
				
		
		

func check_scanned_tile(direction_ray:RayCast2D,direction:Vector2):
	var direction_ray_tile = direction_ray.get_collider()
	match _state:
		States.NO_ITEM:
			
			if direction_ray_tile == null:
				move(direction)
			elif direction_ray_tile.is_in_group("stairs"):
				get_parent().goto_next_level()
				
		States.WITH_ITEM:
			#print(currentItem.get_groups())
			var item_ray_scan_results:Dictionary = currentItem.ray_scan()
			var item_direction_ray:RayCast2D = item_ray_scan_results[direction]
			var item_direction_tile := item_direction_ray.get_collider()
			
#			
				
			
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
				if currentItem != null and currentItem.is_in_group("keys") and item_direction_tile != null and item_direction_tile.is_in_group("doors"):
					open_door(item_direction_tile,direction)
				#empty in front of item
				elif item_direction_tile == null or item_direction_tile.is_in_group("door"):
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
	play_sfx(walking_sfx)

func change_ap(ap_diff:int):
	print(ap)
	ap += ap_diff
	ui.update_ap_label(ap)
	if ap <= 0:
		end_turn()
		pass

func change_hp(hp_diff:int):
	hp = max(0,hp + hp_diff)
	ui.update_hp_label(hp)
	if hp == 0:
		die()
	pass

func take_damage(damage:int):
	animPlayer.play('hit')
	change_hp(-damage)
	play_sfx(hit_sfx)

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
	animate()
	play_sfx(grab_item_sfx)

func drop_item():
	_state = States.NO_ITEM
	currentItem = null
	animate()
	play_sfx(drop_item_sfx)
	
func attack_mob(mob:Actor,currentItem:Actor):
	interact_anim(direction)
	currentItem.interact_anim(direction)
	mob.take_damage(currentItem.attack)
	#yield(mob,"done_taking_damage")
	
	#change_ap(-3)
	pass

func die():
	get_tree().reload_current_scene()
	pass

func start_turn():
	_state = last_state
	ap += max_ap
	ui.update_ap_label(ap)

func end_turn():
	last_state = _state
	_state = States.NOT_TURN
	emit_signal("turn_ended")

func signaled_change_ap():
	change_ap(-3)

func open_door(door,direction):
	_state = States.NO_ITEM
	interact_anim(direction)
	currentItem.interact_anim(direction)
	yield(currentItem.tween,"tween_all_completed")
	door.open()
	var oldItem = currentItem
	drop_item()
	oldItem.opened_door()
	play_sfx(open_door_sfx)
	change_ap(-3)
	pass

func animate():
	match _state:
		States.NO_ITEM:
			current_anim = idle_anim
			sprite.modulate = noitem_colour 
		States.WITH_ITEM:
			current_anim = push_anim
			sprite.modulate = item_colour 
			
	frame = wrapi(frame + 1, 0, frames)
	sprite.frame = current_anim[frame]
	
	if _state == States.NO_ITEM:
		if direction == Vector2.RIGHT:
			sprite.flip_h = false
		if direction == Vector2.LEFT:
			sprite.flip_h = true
	


func pass_ap():
	match _state:
		States.NO_ITEM:
			change_ap(-2)
		States.WITH_ITEM:
				change_ap(-3)


func play_sfx(sfx):
	audio.set_stream(sfx)
	audio.play()
