extends Area2D

onready var sprite = $Sprite
var frame:int = 0
var frames:int = 2

var max_ap:int = 1
var ap:int =  max_ap

var max_recovery:int = 3
var recovery:int = 3

enum States{
	WAITING,
	ACTING
}
var _state = States.WAITING

var max_hp:int = 6
var hp:int = max_hp 

func change_hp(hp_diff):
	hp = max(0, hp + hp_diff)
	if hp == 0:
		#make a real death function later
		die()

func _ready() -> void:
	pass
#	get_parent().get_node("Player").connect("player_moved",self,"on_player_moved")


#func on_player_moved():
#	match _state:
#		States.WAITING:
#			recovery -= 1
#			if recovery == 0:
#				ap = max_ap
#				_state = States.ACTING
#
#		States.ACTING:
#			act()
#			ap -= 1
#			if ap == 0:
#				recovery = max_recovery
#				_state = States.WAITING
			
	

func act():
	var tile = check_tile()
	animate()

func check_tile():
	#idle state: moves randomly, shoot a bunch of rays that checks if the player is found
	#if the mob find the player, go into the seek state, and try to follow the player's path.
	# seek state:
	pass
	
func animate():
	frame = wrapi(frame + 1, 0, frames)
	sprite.frame = frame

func die():
	queue_free()