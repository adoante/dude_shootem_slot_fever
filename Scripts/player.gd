extends CharacterBody3D

@onready var player_ui       : CanvasLayer = $PlayerUI
@onready var weapon_sprite   : AnimatedSprite2D = $PlayerUI/WeaponSprite
@onready var marker_3d       : Marker3D = $Marker3D
@onready var fire_rate_timer : Timer = $FireRateTimer
@onready var player_sprite: AnimatedSprite2D = $PlayerUI/PlayerSprite
@onready var bgm_player: AudioStreamPlayer3D = $BGMPlayer
@onready var hurt_sfx: AudioStreamPlayer3D = $HurtSFX

@export var Bullet: PackedScene
@export var spawn_point: Vector3

@export_group("Speeds")
@export var jump_velocity  : float = 4.5
@export var base_speed     : float = 7.0
@export var rotation_speed : float = 120.0

@export_group("Input Actions")
@export var input_left  : String = "move_left"
@export var input_right : String = "move_right"
@export var input_up    : String = "move_up"
@export var input_down  : String = "move_down"
@export var input_jump  : String = "jump"
@export var input_shoot : String = "shoot"

var move_speed   : float = 0.0

func _ready() -> void:
	if bgm_player.stream:
		bgm_player.stream.loop = true
		bgm_player.play()
	GameManager.player_died.connect(_respawn)
	GameManager.state_changed.connect(_set_fire_rate)
	move_speed += base_speed
	fire_rate_timer.wait_time = GameManager.get_fire_rate()
	
func _physics_process(delta: float) -> void:
	_movement(delta)
	_shoot()

# Private Functions
func _movement(delta: float) -> void:
	#if Input.is_action_just_pressed(input_jump) and is_on_floor()
	#	velocity.y = jump_velocity

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Rotate
	var ang = deg_to_rad(rotation_speed) * delta
	if Input.is_action_pressed(input_right):
		rotate_y(-ang)
	if Input.is_action_pressed(input_left):
		rotate_y(ang)

	# Move forward/back
	var direction = Vector3.ZERO
	if Input.is_action_pressed(input_up):
		direction += -transform.basis.z
	if Input.is_action_pressed(input_down):
		direction += transform.basis.z

	global_position += direction.normalized() * move_speed * delta

	move_and_slide()

func get_player_ui() -> CanvasLayer:
	return player_ui
	
func _shoot() -> void:
	if GameManager.get_reloading():
		return
		
	if Input.is_action_just_pressed("reload") and GameManager.get_bullets_left() < GameManager.get_gun_capacity():
		_reload()
		return
		
	if GameManager.get_bullets_left() == 0:
		_reload()
		return
		
	if fire_rate_timer.time_left > 0:
		return
		
	if Input.is_action_pressed("shoot"):
		var animation = player_ui.get_animations()[GameManager.get_gun_state()]
		weapon_sprite.play(animation)
		GameManager.update_bullets_left(-1)
		_spawn_bullet()
		fire_rate_timer.start()

func _spawn_bullet() -> void:
	var bullet = Bullet.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.transform = marker_3d.global_transform

func _reload():
	GameManager.set_reloading(true)
	
	var capacity = GameManager.get_gun_capacity()
	var bullets_left = GameManager.get_bullets_left()
	var reserve = GameManager.get_ammo()
	var needed = capacity - bullets_left
	var to_load = min(needed, reserve)
	
	GameManager.set_bullets_left(bullets_left + to_load)
	GameManager.update_ammo(-to_load)
	GameManager.get_reload_timer().start()

func _on_fire_rate_timer_timeout() -> void:
	fire_rate_timer.stop()
	print("You can shoot now.")

func _set_fire_rate() -> void:
	fire_rate_timer.wait_time = GameManager.get_fire_rate()

func _respawn() -> void:
	position = spawn_point
	
func get_hurt_sfx() -> AudioStreamPlayer3D:
	return hurt_sfx
