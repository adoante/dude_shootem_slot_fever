extends CharacterBody3D

@onready var player: Node3D = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var target_timer: Timer = $TargetTimer
@onready var marker_3d: Marker3D = $Marker3D
@onready var despawn_timer: Timer = $DespawnTimer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var attack_area: Area3D = $AttackArea
@onready var area_collision_shape_3d: CollisionShape3D = $AttackArea/CollisionShape3D

@export var Bullet: PackedScene = preload("res://Scenes/Objects/Weapons/enemy_bullet.tscn")
@export var player_ammo: PackedScene = preload("res://Scenes/Objects/Weapons/ammo.tscn")

@export var melee            : bool
@export var speed            : float
@export var health           : float
@export var damage           : float
@export var detection_range  : float
@export var wander_radius    : float
@export var wander_threshold : float
@export var attack_rate      : float
@export var money_given      : int
@export var ranged_range     : float
@export var melee_range      : float

var attacking: bool = false
var attack_cooldown: float = 0.0
var target: Vector3
var picking_target: bool = false
var dead: bool = false

func _physics_process(delta: float) -> void:
	if not dead:
		_movement(delta)
		_attack(delta)
		_unstuck()
	
func _movement(delta: float) -> void:
	if not player:
		return

	# Apply gravity
	if not is_on_floor():
		animated_sprite_3d.play("idle")
		velocity += get_gravity() * delta
	else:
		velocity.y = 0

	# Chase player if close, otherwise wander
	var to_player: Vector3 = player.global_position - global_position
	var dist = global_position.distance_to(player.global_position)
	if to_player.length() < detection_range:
		if not melee and dist <= ranged_range:
			animated_sprite_3d.play("shoot")
		else:
			animated_sprite_3d.play("walking")
		look_at(player.global_position, Vector3.UP)
		var direction: Vector3 = (to_player * Vector3(1, 0, 1)).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		_wander()

	move_and_slide()

func _get_random_point_in_radius(radius: float) -> Vector3:
	var angle = randf() * TAU
	var distance = randf_range(radius * 0.5, radius)
	var offset = Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
	return global_position + offset

func _wander() -> void:
	if target == Vector3.ZERO:
		_pick_new_target()
		
	var to_target: Vector3 = target - global_position
	to_target.y = 0
	if to_target.length() > wander_threshold:
		animated_sprite_3d.play("walking")
		var direction: Vector3 = to_target.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		animated_sprite_3d.play("idle")
		_pick_new_target()
		velocity.x = 0
		velocity.z = 0

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0:
		GameManager.update_money(money_given)
		despawn_timer.start()
		animated_sprite_3d.play("dead")
		dead = true
		collision_shape_3d.set_deferred("disabled", true)
		area_collision_shape_3d.set_deferred("disabled", true)
		_spawn_ammo()

func _attack(delta: float) -> void:
	if not player:
		return
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	var dist = global_position.distance_to(player.global_position)

	if attacking and attack_cooldown <= 0.0 and dist <= melee_range and melee:
		GameManager.update_health(-damage)
		player.player_sprite.play("Hurt")
		player.get_hurt_sfx().play()
		attack_cooldown = attack_rate
		
	elif dist <= ranged_range and attack_cooldown <= 0.0 and not melee:
		_spawn_bullet()
		attack_cooldown = attack_rate

func _spawn_ammo() -> void:
	var instance = player_ammo.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position

func _spawn_bullet() -> void:
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.transform = marker_3d.global_transform

func _unstuck() -> void:
	if picking_target:
		_pick_new_target()

func _pick_new_target() -> void:
	target = _get_random_point_in_radius(wander_radius)

func _on_attack_area_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		attacking = true
	if body.is_in_group("walls"):
		picking_target = true
	if body.is_in_group("enemy"):
		picking_target = true

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		attacking = false
	if body.is_in_group("walls"):
		picking_target = false
	if body.is_in_group("enemy"):
		picking_target = false

func _on_despawn_timer_timeout() -> void:
	despawn_timer.stop()
	queue_free()
