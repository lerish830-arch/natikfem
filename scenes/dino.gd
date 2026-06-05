extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
const JUMP_HOLD_FORCE : int = 1800  
const MAX_JUMP_HOLD_TIME : float = 0.35  
const MAX_HEIGHT_Y : float = 80.0  
var jump_hold_timer : float = 0.0
var is_jumping : bool = false

func _physics_process(delta):
	if is_jumping and Input.is_action_pressed("ui_accept") and jump_hold_timer < MAX_JUMP_HOLD_TIME:
		jump_hold_timer += delta
		var hold_progress = jump_hold_timer / MAX_JUMP_HOLD_TIME
		var falloff = 1.0 - smoothstep(0.0, 1.0, hold_progress)
		velocity.y -= JUMP_HOLD_FORCE * falloff * delta
	else:
		velocity.y += GRAVITY * delta
	if position.y < MAX_HEIGHT_Y:
		position.y = MAX_HEIGHT_Y
		velocity.y = 0
		is_jumping = false
	if is_on_floor():
		is_jumping = false
		jump_hold_timer = 0.0
		if not get_parent().game_running:
			$AnimatedSprite2D.play("Idle")
		else:
			$RunCol.disabled = false
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
				is_jumping = true
				jump_hold_timer = 0.0
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("Duck")
				$RunCol.disabled = true
			else:
				$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("jump")
	move_and_slide()
