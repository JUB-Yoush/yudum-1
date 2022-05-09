extends Area2D

onready var sprite = $Sprite
onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size:int = 16
var frame = 0
var speed = 5
var walk_anim = [0,1]
var push_anim = [2,3]
var current_anim:Array
var currentSword:Area2D
var sword_dir:Vector2
signal player_moved(dir)

enum STATES{
	WALK,
	PUSH,
	DEAD
}
var _state = STATES.WALK

# ANIMATIONS -----------------------------

var inputs = {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up":Vector2.UP,
				"down": Vector2.DOWN}

func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)
	#position += Vector2.ONE * tile_size

func _unhandled_input(event: InputEvent) -> void:
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			check(dir)
	if event.is_action_pressed("grab"):
		match _state:
			STATES.WALK:
				find_sword()
				
			STATES.PUSH:
				drop_sword()
		

func move(dir) -> void:
	emit_signal("player_moved",inputs[dir])
	#move_tween(dir)
	#position += inputs[dir] * tile_size
	move_tween(dir)
	animate()

func move_tween(dir) -> void:
	tween.interpolate_property(self, "position",position, position + (inputs[dir] * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func check(dir):
	if inputs[dir] == sword_dir:
		pass
		#ray.position = inputs[dir] * tile_size * 2
	ray.cast_to = inputs[dir] * tile_size 
	ray.force_raycast_update()
	var tile = ray.get_collider()
	
	if tile == null:
		match _state:
			STATES.WALK:
				move(dir)
				
			STATES.PUSH:
				move(dir)
				currentSword.move(inputs[dir], speed)
	elif tile.is_in_group("walls") or tile.is_in_group("swords"):
		pass

func animate() -> void:
	match _state:
		STATES.WALK:
			current_anim = walk_anim
		STATES.PUSH:
			current_anim = push_anim	
	frame = wrapi(frame + 1, 0, 2)
	sprite.frame = current_anim[frame]
	
func find_sword():
	for dir in inputs.keys():
		ray.cast_to = inputs[dir] * tile_size
		ray.force_raycast_update()
		var tile = ray.get_collider()
		if tile != null:
			print(tile.get_groups())
			if tile.is_in_group("swords"):
				found_sword(tile,dir)
			
			
		
		
func found_sword(tile,dir):
	_state = STATES.PUSH
	currentSword = tile
	sword_dir = inputs[dir]
	#tile.connect("player_moved",tile,"on_player_moved")

func drop_sword():
	_state = STATES.WALK
	currentSword = null
