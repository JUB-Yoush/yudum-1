extends Area2D

var opened = false
onready var sprite = $Sprite
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#connect("area_entered",self,"on_area_entered")
	pass # Replace with function body.

func open():
	get_parent().get_node("Player").change_ap(-3)
	queue_free()
	


func on_area_entered(area:Area2D):
	if area.is_in_group("keys"):
		area.opened_door()
		open()
	
