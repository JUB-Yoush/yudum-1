extends Node2D

onready var player = get_node("Player")
onready var audio = $AudioStreamPlayer
var mob_die_sfx := load("res://assets/sounds/mob_die_new.wav")
var mob_index = 0
export var next_stage:PackedScene
var Key = preload("res://src/actors/items/Key.tscn")
func _ready() -> void:
	player.connect("turn_ended",self,"on_player_turn_ended")
	

func on_player_turn_ended():
	var mobs = get_mobs()
	if mobs.size() == 0:
		player.start_turn()
	else:
		start_mob_turns(mobs)


func start_mob_turns(mobs):
	var mob = mobs[mob_index]
	mob.connect("turn_ended",self,"on_mob_turn_ended")
	mob.act()
	
	
func on_mob_turn_ended(mob):
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

func goto_next_level():
	get_tree().change_scene_to(next_stage)

func make_key(spawn_position:Vector2):
	var key = Key.instance()
	key.position = spawn_position
	add_child(key)

func play_sfx(sfx):
	audio.set_stream(sfx)
	audio.play()

	
