extends Area3D

@export var speed : float = 20.0
@onready var shoot_sfx: AudioStreamPlayer3D = $ShootSFX

func _ready() -> void:
	shoot_sfx.play()

func _process(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z
	global_position += forward * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		body.take_damage(GameManager.get_gun_damage())
	queue_free()

func _on_despawn_timer_timeout() -> void:
	queue_free()
