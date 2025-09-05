extends Node3D

@export var object_to_spawn: PackedScene
@export var spawn_interval: float = 1.0

var spawn_timer := 0.0

func _process(delta):
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_object()

func spawn_object():
	if not is_inside_tree():
		return  # Don't spawn if this node isn't in the scene yet

	if object_to_spawn and GameManager.can_spawn():
		var instance = object_to_spawn.instantiate()
		get_tree().current_scene.add_child(instance)
		instance.global_position = global_position
		GameManager.register_enemy(instance)
