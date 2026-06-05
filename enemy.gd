extends CharacterBody2D
@export var shoot_interval: float = 2.0
const BulletScene = preload("res://scenes/enemy_bullet.tscn")
func _ready():
	$AnimatedSprite2D.play("idle_charecter")
	$ShootTimer.wait_time = shoot_interval
	$ShootTimer.start()
	$ShootTimer.timeout.connect(_on_shoot_timer_timeout)
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += 980 * delta
	else:
		velocity.y = 0
	move_and_slide()
func _on_shoot_timer_timeout():
	var bullet = BulletScene.instantiate()
	bullet.global_position = $BulletSpawnPoint.global_position
	get_parent().add_child(bullet)
func die():
	$AnimatedSprite2D.play("death_charecter")
	await $AnimatedSprite2D.animation_finished
	queue_free()
