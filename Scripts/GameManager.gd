extends Node

signal state_changed
signal player_died

const ROOM_SIZE = 50
const GRID_RADIUS = 1

@onready var reload_timer: Timer = $ReloadTimer
@onready var slot_machine_ui: CanvasLayer = $SlotMachineUI
@onready var bgm: AudioStreamPlayer2D = $BGM

enum GunState {
	#BAT,
	PISTOL,
	SHOTGUN,
	MACHINE_GUN,
	MINIGUN,
}

@export var max_enemies    : int = 50
@export var starting_ammo  : int
@export var max_health     : int
@export var starting_money : int
@export var room_scenes    : Array[PackedScene]
@export var wall_scene     : PackedScene

var current_enemies : int = 0
var money           : int
var health          : float
var ammo            : int
var damage_boost    : float = 0
var gun_capacity    : int
var reload_time     : int
var bullets_left    : int
var gun_damage      : float
var fire_rate       : float
	
var weapons = {
	#GunState.BAT:         preload("res://Weapon/Bat.tres"),
	GunState.PISTOL:      preload("res://Weapon/Pistol.tres"),
	GunState.SHOTGUN:     preload("res://Weapon/Shotgun.tres"),
	GunState.MACHINE_GUN: preload("res://Weapon/MachineGun.tres"),
	GunState.MINIGUN:     preload("res://Weapon/Minigun.tres"),
}

var reloading     : bool = false
var current_state : GunState
var prev_state    : GunState

func _process(_delta: float) -> void:
	pass

func _ready():
	spawn_grid()
	health = max_health
	ammo = starting_ammo
	money = starting_money
	set_gun_state(GunState.PISTOL)

func spawn_grid():
	for x in range(-1, 2):
		for z in range(-1, 2):
			if x == 0 and z == 0:
				continue
			
			var scene = room_scenes.pick_random()
			var room = scene.instantiate()
			
			room.position = Vector3(x * ROOM_SIZE, 0, z * ROOM_SIZE)
			add_child(room)
			print("Placing room at: ", x * ROOM_SIZE, ", ", z * ROOM_SIZE)

func can_spawn() -> bool:
	return current_enemies < max_enemies

func register_enemy(enemy: Node) -> void:
	current_enemies += 1
	# Remove automatically when enemy is freed
	enemy.tree_exited.connect(_on_enemy_removed)

func _on_enemy_removed() -> void:
	current_enemies = max(0, current_enemies - 1)

func die() -> void:
	player_died.emit()
	set_gun_state(GunState.PISTOL)
	health = max_health
	ammo = starting_ammo
	money = starting_money

func get_max_health() -> float:
	return max_health

func get_fire_rate() -> float:
	return fire_rate

func get_ammo() -> int:
	return ammo

func update_ammo(amount: int) -> void:
	ammo += amount

func get_gun_damage() -> float:
	return gun_damage

func set_gun_damage(amount: int) -> void:
	gun_damage = amount

func get_gun_capacity() -> int:
	return gun_capacity

func set_gun_capacity(amount: int) -> void:
	gun_capacity = amount

func get_bullets_left() -> int:
	return bullets_left

func update_bullets_left(amount: int) -> void:
	bullets_left += amount

func set_bullets_left(amount: int) -> void:
	bullets_left = amount

func get_health() -> float:
	return health

func update_health(amount: float) -> void:
	health += amount + (amount * damage_boost)
	if health <= 0:
		die()
	
func set_damage_boost(amount: float) -> void:
	damage_boost = amount
	
func get_money() -> int:
	return money

func update_money(amount: int) -> void:
	money += amount

func set_gun_state(state: GunState):
	prev_state = current_state
	current_state = state
	
	var weapon: Weapon = weapons[state]
	gun_damage = weapon.damage
	gun_capacity = weapon.gun_capacity
	reload_time = weapon.reload_time
	fire_rate = weapon.fire_rate
	bullets_left = gun_capacity
	
	_setup_timer()
	
	print("setting up weapon")
	
	state_changed.emit()

func get_slot_machine_ui() -> CanvasLayer:
	return slot_machine_ui

func get_gun_state() -> GunState:
	return current_state
	
func get_prev_state() -> GunState:
	return prev_state

func set_reloading(reload: bool) -> void:
	reloading = reload
	
func get_reloading() -> bool:
	return reloading

func _setup_timer():
	reload_timer.wait_time = reload_time

func get_reload_timer() -> Timer:
	return reload_timer

func _on_reload_timer_timeout() -> void:
	reload_timer.stop()
	reloading = false

func get_bgm() -> AudioStreamPlayer2D:
	return bgm
