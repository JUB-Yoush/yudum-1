extends Actor


func _ready() -> void:
	frames = 1

func move(direction:Vector2):
	move_by_tween(direction)

func opened_door():
	queue_free()
	pass
