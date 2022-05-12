extends Node2D

onready var player = get_node("Player")
var mob_index = 0


func _ready() -> void:
	player.connect("turn_ended",self,"on_player_turn_ended")
	

func on_player_turn_ended():
	var mobs = get_mobs()
	start_mob_turns(mobs)


func start_mob_turns(mobs):
	var mob = mobs[mob_index]
	mob.connect("turn_ended",self,"on_mob_turn_ended")
	mob.act()
	
	
func on_mob_turn_ended(mob):
	print('turn over')
	mob.disconnect("turn_ended",self,"on_mob_turn_ended")
	var mobs:Array = get_mobs()
	mob_index = min(mob_index + 1, mobs.size())
	if mob_index == mobs.size():
		mob_index = 0
		player.start_turn()
		
	else:
		start_mob_turns(mobs)
	

func get_mobs():
	return get_tree().get_nodes_in_group("mobs")
