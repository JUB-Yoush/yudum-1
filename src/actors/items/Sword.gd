extends Actor

var attack = 3

func _ready() -> void:
	frames = 1

func move(direction:Vector2):
	move_by_tween(direction)
