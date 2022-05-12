extends Area2D


#signal player_moved(dir)
onready var tween = $Tween
onready var ray = $RayCast2D
var tile_size = 16
var damage:int = 3
signal player_let_go

func on_moved_item(dir,speed):
	ray.cast_to = dir * tile_size 
	ray.force_raycast_update()
	var tile = ray.get_collider()
	if tile == null or tile.is_in_group("player") or tile.is_in_group("mobs"):
		move(dir,speed)
	else:
		emit_signal("player_let_go")


func move(dir,speed):
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()


func get_check_tile(dir):
	ray.cast_to = dir * tile_size 
	ray.force_raycast_update()
	var tile = ray.get_collider()
	return tile
		
	

