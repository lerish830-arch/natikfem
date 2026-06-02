extends Node

var stump_scene = preload("res://scenes/stump.tscn")
var rock_scene = preload("res://scenes/rocks.tscn")
var barrels_scene = preload("res://scenes/barrels.tscn")
var shield_scene = preload("res://scenes/shield.tscn")

var obstacle_types := [stump_scene, rock_scene, barrels_scene]
var obstacles : Array

# game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var difficulty
const MAX_DIFFICULTY : int = 2

var score : int
const SCORE_MODIFIER : int = 12
var high_score : int = 0
var speed : float

const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000

var screen_size : Vector2i
var ground_height : int
var game_running : bool
var game_over_state : bool = false
var last_obs

var cycle_timer := 0.0
var is_night := false
var has_shield := false

func _ready() -> void:
	screen_size = get_window().size
	ground_height = $ground.get_node("Sprite2D").texture.get_height()
	$CanvasLayer.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	speed = START_SPEED
	game_running = false
	game_over_state = false
	difficulty = 0

	cycle_timer = 0.0
	is_night = false
	has_shield = false
	$Dino/ShieldSprite.hide()
	$CanvasLayer2/ColorRect.color.a = 0.0

	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$ground.position = Vector2i(0, 0)

	$HUD.get_node("startlabel").show()
	$HUD.get_node("HighScore").text = "HIGH SCORE: " + str(int(high_score / SCORE_MODIFIER))

	$CanvasLayer.hide()

func _process(_delta: float) -> void:
	if game_running:
		cycle_timer += _delta

		if cycle_timer >= 15:
			cycle_timer = 0

			if is_night:
				$CanvasLayer2/ColorRect.color.a = 0.0
				is_night = false
			else:
				$CanvasLayer2/ColorRect.color.a = 120.0 / 255.0
				is_night = true

		speed = START_SPEED + score / SPEED_MODIFIER

		if speed > MAX_SPEED:
			speed = MAX_SPEED

		adjust_difficulty()
		generate_obs()
		generate_shield()

		$Dino.position.x += speed
		$Camera2D.position.x += speed

		score += speed
		show_score()

		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x

		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)

	elif not game_over_state:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("startlabel").hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var max_obs = difficulty + 1

		for i in range(randi() % max_obs + 1):
			var obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale

			var obs_x := int(screen_size.x + score + 100 + (i * 100))
			var obs_y := int(screen_size.y - ground_height - (obs_height * obs_scale.y / 2.0) + 5)

			last_obs = obs
			add_obs(obs, obs_x, obs_y)

func generate_shield():
	if !has_shield and randi() % 800 == 0:
		var shield = shield_scene.instantiate()
		shield.position = Vector2(
			$Camera2D.position.x + screen_size.x,
			450
		)
		add_child(shield)
		obstacles.append(shield)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func hit_obs(body):
	if body.name == "Dino":
		if has_shield:
			has_shield = false
			$Dino/ShieldSprite.hide()
			print("Shield used!")
			return

		game_over()

func collect_shield(shield):
	has_shield = true
	$Dino/ShieldSprite.show()
	print("Shield collected!")
	obstacles.erase(shield)
	shield.queue_free()

func show_score():
	$HUD.get_node("Scorelabel").text = "SCORE: " + str(int(score / SCORE_MODIFIER))

func check_high_score():
	if score > high_score:
		high_score = score
	$HUD.get_node("HighScore").text = "HIGH SCORE: " + str(int(high_score / SCORE_MODIFIER))

func adjust_difficulty():
	difficulty = int(score / float(SPEED_MODIFIER))
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	game_running = false
	game_over_state = true
	speed = 0
	check_high_score()
	print("Game Over")
	$CanvasLayer.show()
	
