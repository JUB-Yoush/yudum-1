extends Area2D

onready var sprite = $Sprite
onready var ray = $RayCast2D
onready var tween = $Tween

var tile_size = 16
var speed = 7

var frame:int = 0
var frames:int = 2

var max_ap:int = 1
var ap:int =  max_ap

var max_recovery:int = 3
var recovery:int = 3

var max_hp:int = 6
var hp:int = max_hp 

enum States{
	LOOKING,
	FOUND
}
var _state = States.LOOKING

var directions = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]


func change_hp(hp_diff):
	hp = max(0, hp + hp_diff)
	if hp == 0:
		#make a real death function later
		die()

func _ready() -> void:
	pass
#	get_parent().get_node("Player").connect("player_moved",self,"on_player_moved")


func act():
	match _state:
		States.LOOKING:
			looking_act()
			animate()

func check_tile(dir:Vector2):
	ray.cast_to = dir * tile_size
	ray.force_raycast_update()
	var tile = ray.get_collider()
	return tile
	
func animate():
	frame = wrapi(frame + 1, 0, frames)
	sprite.frame = frame

func die():
	queue_free()

func looking_act():
	var tile_found = false
	var rng_dir 
	while tile_found == false:
		rng_dir = directions[randi() % directions.size()]
		var tile = check_tile(rng_dir)
		if tile == null:
			tile_found = true	
	move_tween(rng_dir)
	

func move_tween(dir):
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

