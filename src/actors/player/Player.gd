extends Area2D

onready var sprite = $Sprite
onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size:int = 16
var frame = 0
var speed = 7
var IDLE_anim = [0,1]
var push_anim = [2,3]
var current_anim:Array
var currentItem:Area2D
var sword_dir:Vector2
signal moved_item(dir,speed)
signal player_moved

enum States{
	IDLE,
	PUSH,
	WALKING,
	DEAD
}
var _state = States.IDLE

# ANIMATIONS -----------------------------

var inputs:Dictionary= {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up":Vector2.UP,
				"down": Vector2.DOWN}

var directions = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
var inputted_dir:Vector2

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
				find_sword()
				
			States.PUSH:
				drop_item()
		

func move(dir) -> void:
	emit_signal("moved_item",dir,speed)
	emit_signal("player_moved")
	move_tween(dir)
	animate(dir)

func move_tween(dir) -> void:
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func check(dir):
	ray.cast_to = dir * tile_size 
	ray.force_raycast_update()
	var tile = ray.get_collider()
	
	match _state:
			States.IDLE:
				if tile == null:
					move(dir)
				
			States.PUSH:
				if tile != null and tile.is_in_group("items"):
					var old_tile = tile
					old_tile.collision_layer = 4
					ray.cast_to = dir * tile_size * 2
					ray.force_raycast_update()
					tile = ray.get_collider()
					old_tile.collision_layer = 1
					
					
				if tile == null:
					move(dir)
					#currentItem.move(dir, speed)
					emit_signal("moved_item",dir,speed)
					
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
		if dir == Vector2(1,0):
			sprite.flip_h = false
		if dir == Vector2(-1,0):
			sprite.flip_h = true
	
func find_sword():
	for dir in directions:
		ray.cast_to = dir * tile_size
		ray.force_raycast_update()
		var tile = ray.get_collider()
		if tile != null:
			print(tile.get_groups())
			if tile.is_in_group("swords"):
				found_item(tile,dir)
			
func found_item(tile,dir):
	_state = States.PUSH
	currentItem = tile
	connect("moved_item",currentItem,"on_moved_item")
	currentItem.connect("player_let_go",self,"drop_item")
	sword_dir = dir
	animate(dir)
	

func drop_item():
	_state = States.IDLE
	disconnect("moved_item",currentItem,"on_moved_item")
	currentItem.disconnect("player_let_go",self,"drop_item")
	currentItem = null
	animate(inputted_dir)
