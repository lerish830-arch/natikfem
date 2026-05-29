extends Node
 #game variables
const DINO_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)

var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
func _ready() -> void:
	pass 
func new_game():
	$Dino.position = DINO_START_POS
	$Dino.velocity = Vector2i(0, 0)
	$Camera2D.position= CAM_START_POS
	$ground.position = Vector2i(0, 0) 
	

func _process(delta: float) -> void:
	speed = START_SPEED 
	$dino.position.x += speed
	$Camera2D.position.x += speed
