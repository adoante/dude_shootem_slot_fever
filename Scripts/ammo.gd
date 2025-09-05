extends Area3D

@export var ammo_to_give: int
@onready var pickup_sfx: AudioStreamPlayer3D = $PickupSFX
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var sprite_3d: Sprite3D = $Sprite3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.update_ammo(ammo_to_give)
		pickup_sfx.play()
		collision_shape_3d.set_deferred("disabled", false)
		sprite_3d.visible = false
		await pickup_sfx.finished
		queue_free()
