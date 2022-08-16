extends Node2D

export(String) var species
export(String) var nickname
enum Moves {
	SnapFreeze
}
var NameTable = {
	Moves.SnapFreeze: "Snap Freeze"
}
var PpTable = {
	Moves.SnapFreeze: 15
}

export(Array, Moves) var moves = [Moves.SnapFreeze]

var pp = {}

const Common = preload("res://Common.gd")
const Place = Common.Place

var place : Place setget set_place, get_place
func set_place(p):
	place = p
	global_position = p.location.global_position
func get_place(): return place

var allowJump = true
func _ready():
	for m in moves:
		pp[m] = PpTable[m]
onready var world = get_tree().get_nodes_in_group("World")[0]

func snap_freeze():
	var cast = load("res://IceBeamCast.tscn").instance()
	world.add_child(cast)
	cast.global_position = $Sprite/FireBeam.global_position
	yield(cast, "tree_exited")
	
	var c = load("res://IceBeamProjectile.tscn").instance()
	world.add_child(c)
	c.global_position = global_position
	c.global_position.x = $Sprite/FireBeam.global_position.x
	c.get_node("Sprite").global_position.y = $Sprite/FireBeam.global_position.y
	var t = Tween.new()
	t.interpolate_property(c, "global_position", c.global_position, c.global_position + transform.x * (512 * 3), 3.0, Tween.TRANS_LINEAR)
	world.add_child(t)
	t.start()
	t.connect("tween_all_completed", t, "queue_free")
	t.connect("tween_all_completed", c, "detonate")
	
	while is_instance_valid(c):
		if Input.is_key_pressed(KEY_G):
			c.detonate()
		yield(get_tree(), "idle_frame")
		
	
var jumpReady = true
func jump():
	$Anim.play("Jump")
	jumpReady = false
	yield(get_tree().create_timer(1.0), "timeout")
	jumpReady = true

func take_damage(proj):
	pass
