extends Actor

# MOB VARIABLES ---------------------------
var max_hp := 6
var hp := max_hp

var max_ap := 1
var ap = 1

func change_hp(hp_diff):
	hp = max(0, hp + hp_diff)
	if hp == 0:
		die()
	

func _ready() -> void:
	frames = 2
	

func act():
	pass

func take_damage(damage:int):
	animPlayer.play('hit')
	change_hp(-damage)


func die():
	queue_free()
