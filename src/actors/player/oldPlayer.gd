extends Area2D

onready var sprite = $Sprite
onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size:int = 16

var speed = 7


var item_dir:Vector2

signal moved_item(dir,speed)
signal player_turn_ended
signal player_moved

# GAME STATS ---------------------
var max_hp:= 5
var hp:= max_hp

var max_ap:= 6
var ap:= max_ap setget change_ap

var currentItem:Area2D

enum States{
	IDLE,
	PUSH,
	RECOVERING
}
var _state = States.IDLE

# ANIMATIONS -----------------------------
var frame = 0
var IDLE_anim = [0,1]
var push_anim = [2,3]
var current_anim:Array

# MOVEMENT / PATHFINDING
var inputs:Dictionary= {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up":Vector2.UP,
				"down": Vector2.DOWN}

var directions = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]

onready var rays = $Rays
onready var rayR
onready var rayL
onready var rayU
onready var rayD

var ray_tiles = {
	Vector2.RIGHT:null
}


var inputted_dir:Vector2


func change_ap(ap_diff):
	ap += ap_diff
	print(ap)
	if ap <= 0:
		end_turn()
	pass




func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	#position += Vector2.ONE * tile_size

func _unhandled_input(event: InputEvent) -> void:
	if tween.is_active():
		return
	for input in inputs:
		if event.is_action_pressed(input):
			inputted_dir = inputs[input]
			check(inputted_dir)
	
	if event.is_action_pressed("grab"):
		match _state:
			States.IDLE:
				find_item()
				
			States.PUSH:
				drop_item()
		

func move(dir) -> void:
	match _state:
		States.IDLE:
			emit_signal("moved_item",dir,speed)
			emit_signal("player_moved")
			move_tween(dir)
			animate(dir)
			change_ap(-2)
				
		States.PUSH:
			emit_signal("moved_item",dir,speed)
			emit_signal("player_moved")
			move_tween(dir)
			animate(dir)
			change_ap(-3)
		
	

func move_tween(dir) -> void:
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func check(dir):
	match _state:
		States.IDLE:
			var tile = check_tile(dir)
			if tile == null:
				move(dir)
				
		States.PUSH:
			var tile = check_tile(dir)
			var item_check_tile = currentItem.get_check_tile(dir)
			
			if item_check_tile != null and item_check_tile.is_in_group("mobs"):
				attack_mob(item_check_tile, currentItem)
				
			#if going in dir of item, use items check from same dir
			if tile != null and tile.is_in_group("items"):
				if item_check_tile == null:
					tile = item_check_tile
					
					
			if tile == null:
				
				emit_signal("moved_item",dir,speed)
				move(dir)
				
				
					
			ray.position = Vector2(8,8)
			ray.cast_to = dir * tile_size

	
func animate(dir) -> void:
	match _state:
		States.IDLE:
			current_anim = IDLE_anim
		States.PUSH:
			current_anim = push_anim
			
	frame = wrapi(frame + 1, 0, 2)
	sprite.frame = current_anim[frame]
	
	if _state == States.IDLE:
		if dir == Vector2.RIGHT:
			sprite.flip_h = false
		if dir == Vector2.LEFT:
			sprite.flip_h = true
	
func find_item():
	#print(inputted_dir)
	var tile = check_tile(inputted_dir)
	if tile != null and tile.is_in_group("items"):
		found_item(tile,inputted_dir)

func found_item(tile,dir):
	if currentItem == null:
		
		_state = States.PUSH
		currentItem = tile
		connect("moved_item",currentItem,"on_moved_item")
		currentItem.connect("player_let_go",self,"drop_item")
		item_dir = dir
		if dir == Vector2.RIGHT:
			sprite.flip_h = false
		if dir == Vector2.LEFT:
			sprite.flip_h = true
		animate(dir)
	

func drop_item():
	_state = States.IDLE
	disconnect("moved_item",currentItem,"on_moved_item")
	currentItem.disconnect("player_let_go",self,"drop_item")
	currentItem = null
	animate(inputted_dir)

func check_tile(dir):
	ray.cast_to = dir * tile_size
	ray.force_raycast_update()
	var tile = ray.get_collider()
	return tile

func end_turn():
	emit_signal("player_turn_ended")

func start_turn():
	change_ap(max_ap)
	
func attack_mob(mob,item):
	print("attack mob")
	move_tween(inputted_dir)
	item.move(inputted_dir,speed)
	yield(get_tree().create_timer(speed * 0.025), "timeout")
	move_tween(-inputted_dir)
	item.move(-inputted_dir,speed)
	
	#move up
	#make mob take damage
	#wait a lil bit
	#move back 
	mob.change_hp(-item.damage)
