extends Node2D

func _ready() -> void:
	print("platform ready")
	$Hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("hitbox touched by: ", body.name)
	if body.has_method("_get_hit"):
		body._get_hit()
