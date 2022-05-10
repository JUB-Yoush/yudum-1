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
var currentSword:Area2D
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
				drop_sword()
		

func move(dir) -> void:
	emit_signal("moved_item",dir,speed)
	emit_signal("player_moved")
	move_tween(dir)
	animate(dir)

func move_tween(dir) -> void:
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func check(dir):
	if dir == sword_dir:
		pass
		#ray.position = dir * tile_size * 2
	ray.cast_to = dir * tile_size 
	ray.force_raycast_update()
	var tile = ray.get_collider()
	
	if tile == null:
		match _state:
			States.IDLE:
				move(dir)
				
			States.PUSH:
				move(dir)
				#currentSword.move(dir, speed)
				emit_signal("moved_item",dir,speed)
	elif tile.is_in_group("walls") or tile.is_in_group("items"):
		pass

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
			if tile.is_in_group("items"):
				found_sword(tile,dir)
			
func found_sword(tile,dir):
	_state = States.PUSH
	currentSword = tile
	connect("moved_item",currentSword,"on_moved_item")
	sword_dir = dir
	animate(dir)
	#tile.connect("moved_item",tile,"on_moved_item")

func drop_sword():
	_state = States.IDLE
	disconnect("moved_item",currentSword,"on_moved_item")
	currentSword = null
	animate(inputted_dir)
