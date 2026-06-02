extends Area2D
func _ready() -> void:
	body_entered.connect(_on_body_entered)
func _on_body_entered(body):
	if body.name == "Dino":
		get_parent().collect_shield(self)
