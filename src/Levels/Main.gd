extends Node2D

#onready var player = get_node("Player")
func _ready() -> void:
	pass
	#player.connect("player_turn_ended",self,"on_player_turn_ended")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func on_player_turn_ended():
	
	#loop thru every enemy
	#have them run their action
	#once all have run, run player.start_turn()
	
	var mobs := get_tree().get_nodes_in_group("mobs")
	for mob in mobs:
		mob.act()
	#player.start_turn()
	pass
