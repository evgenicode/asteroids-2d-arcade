extends Area2D

@export var bullet_scene: PackedScene
@export var speed = 150
@export var rotation_speed = 120
@export var health = 3

var follow = PathFollow2D.new()
var target = null

func _ready():
	$Sprite2D.frame = randi() % 3
	var path = $EnemyPaths.get_children() [randi() % $EnemyPaths.get_child_count()]
	path.add_child(follow)
	follow.loop = false

func _on_gun_cooldown_timeout():
	pass # Replace with function body.
