extends Area3D

@export var speed : float = 20.0

func _process(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z
	global_position += forward * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.update_health(-1)
		body.player_sprite.play("Hurt")
		body.get_hurt_sfx().play()
	queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
