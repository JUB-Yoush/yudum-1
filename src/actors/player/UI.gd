extends Control

onready var hpLabel := $TextureRect/HpLabel
onready var apLabel := $TextureRect/ApLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func update_hp_label(hp_value:int):
	hpLabel.text = "hp:" + str(hp_value)

func update_ap_label(ap_value:int):
	apLabel.text = "ap:" + str(ap_value)
