extends Area2D
class_name Actor

onready var sprite := $Sprite
onready var tween := $Tween
onready var animPlayer := $AnimationPlayer

var tile_size:int = 16
var speed:int = 7

var frame:int = 0
var frames


# MOVEMENT / PATHFINDING
var directions:Dictionary= {"right": Vector2.RIGHT,
				"left": Vector2.LEFT,
				"up":Vector2.UP,
				"down": Vector2.DOWN}

var direction:Vector2 = Vector2.ZERO
var direction_ray:RayCast2D

onready var rays:Node2D = $Rays
onready var rayR:RayCast2D = $Rays/RayR
onready var rayL:RayCast2D = $Rays/RayL
onready var rayU:RayCast2D = $Rays/RayU
onready var rayD:RayCast2D = $Rays/RayD

var ray_scan_results:Dictionary = {
	Vector2.RIGHT:null,
	Vector2.LEFT:null,
	Vector2.UP:null,
	Vector2.DOWN:null
}

func ray_scan():
	for ray in rays.get_children():
		ray.force_raycast_update()
		ray_scan_results[ray.cast_to.normalized()] = ray
	return ray_scan_results
	

func _ready() -> void:
	position = position.snapped(Vector2.ONE * tile_size)

func move_by_tween(direction) -> void:
	tween.interpolate_property(self, "position",position, position + (direction * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()

func interact_anim(direction:Vector2) -> void:
	tween.interpolate_property(self, "position",position, position + (direction * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(speed * 0.025), "timeout")
	tween.interpolate_property(self, "position",position, position + (-direction * tile_size), 1.0/speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(get_tree().create_timer(speed * 0.05), "timeout")

func animate():
	frame = wrapi(frame + 1, 0, frames)
	sprite.frame = frame


