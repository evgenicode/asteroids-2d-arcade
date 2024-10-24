extends Node

@export var rock_scene : PackedScene
@export var enemy_scene: PackedScene

var screensize = Vector2.ZERO
var level = 0
var score = 0
var playing = false


func _ready():
	screensize = get_viewport().get_visible_rect().size
	#for development only
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), -20)
	
	
func _process(delta):
	if not playing:
		return
	if get_tree().get_nodes_in_group("rocks").size() == 0:
		new_level()
		
func new_game():
	#remove any old rocks from previous game
	get_tree().call_group("rocks", "queue_free")
	level = 0
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready!")
	$Player.reset()
	await $HUD/Timer.timeout
	playing = true
	$Music.play()
	
func new_level():
	level += 1
	$HUD.show_message("Wave %s" % level)
	for i in level:
		spawn_rock(3)
	$LevelupSound.play()	
	$EnemyTimer.start(randf_range(5, 10))
	
		
func game_over():
	playing = false
	$HUD.game_over()
	$Music.stop()
		
func spawn_rock(size, pos=null, vel=null):
	if pos == null:
		$RockPath/RockSpawn.progress = randi()
		pos = $RockPath/RockSpawn.position
	if vel == null:
		vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(50, 125)
	var r = rock_scene.instantiate()
	r.screensize = screensize
	r.start(pos, vel, size)
	call_deferred("add_child", r)
	r.exploded.connect(self._on_rock_exploded)

func _on_rock_exploded(size, radius, pos, vel):
	$ExplosionSound.play()
	if size <= 1:
		$HUD.update_score(size)
		return
	for offset in [-1, 1]:	
		var dir = $Player.position.direction_to(pos).orthogonal() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size - 1, newpos, newvel)
	$HUD.update_score(size)
		
func _input(event):
	if event.is_action_pressed("pause"):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		var message = $HUD/VBoxContainer/Message
		if get_tree().paused:
			message.text = "Paused"
			message.show()
		else:
			message.text = ""
			message.hide()


func _on_enemy_timer_timeout():
	var e = enemy_scene.instantiate()
	add_child(e)
	e.target = $Player
	e.connect("enemy_dead", Callable(self, "_on_enemy_destroyed"))
	$EnemyTimer.start(randf_range(20, 40))
	
	
func _on_enemy_destroyed():
	$HUD.update_score(5)
