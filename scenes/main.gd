extends Node

var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rocks.tscn")
var barrels_scene = preload("res://scenes/barrels.tscn")
var bird_scene = preload("res://scenes/bird.tscn")

var obstacle_types := [stump_scene, rock_scene, barrels_scene]
var obstacles : Array
var bird_heights = [200, 390]

# game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var score : int
const SCORE_MODIFIER : int = 12
var speed : float

const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000

var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	new_game()

func new_game():
	score = 0
	show_score()
	speed = START_SPEED
	game_running = false

	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)
	$HUD.get_node("startlabel").show()

func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER

		if speed > MAX_SPEED:
			speed = MAX_SPEED

		generate_obs()

		$Dino.position.x += speed
		$Camera2D.position.x += speed

		score += speed
		show_score()

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x

	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("startlabel").hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var max_obs = 3

		for i in range(randi() % max_obs + 1):
			var obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5

			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	add_child(obs)
	obstacles.append(obs)

func show_score():
	$HUD.get_node("Scorelabel").text = "SCORE: " + str(score / SCORE_MODIFIER)
