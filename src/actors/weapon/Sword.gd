extends Area2D


#signal player_moved(dir)
onready var tween = $Tween
var tile_size = 16

func on_moved_item(dir,speed):
	move(dir,speed)


func move(dir,speed):
	tween.interpolate_property(self, "position",position, position + (dir * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

	
