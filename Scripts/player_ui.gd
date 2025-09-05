extends CanvasLayer

@onready var ammo: Label = $Ammo
@onready var bullets: Label = $Bullets
@onready var reload: Label = $Reload
@onready var health: Label = $Health
@onready var money: Label = $Money
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player = get_parent()

@export_group("Weapon Animations")
@export var anim_bat         : String = "bat"
@export var anim_machine_gun : String = "machine_gun"
@export var anim_minigun     : String = "minigun"
@export var anim_pistol      : String = "pistol"
@export var anim_shotgun     : String = "shotgun"

func _ready() -> void:
	weapon_sprite.animation = get_animations()[GameManager.get_gun_state()]
	weapon_sprite.frame = 0
	GameManager.state_changed.connect(_on_weapon_changed)

func _process(_delta: float) -> void:
	var reload_time_left: int = int(GameManager.get_reload_timer().time_left)
	
	ammo.text    = str(GameManager.get_ammo())
	bullets.text = str(GameManager.get_bullets_left())
	health.text  = str(int(GameManager.get_health()/GameManager.get_max_health() * 100))
	money.text   = str(GameManager.get_money())
	
	if GameManager.get_reloading():
		reload.text = "Reloading: %d" % reload_time_left
	else:
		reload.text = ""

func get_animations() -> Dictionary:
	return {
		#GameManager.GunState.BAT: anim_bat,
		GameManager.GunState.PISTOL: anim_pistol,
		GameManager.GunState.MINIGUN: anim_minigun,
		GameManager.GunState.MACHINE_GUN: anim_machine_gun,
		GameManager.GunState.SHOTGUN: anim_shotgun,
	}

func _on_weapon_sprite_animation_finished() -> void:
	weapon_sprite.frame = 0

func _on_weapon_changed() -> void:
	weapon_sprite.animation = get_animations()[GameManager.get_gun_state()]
	weapon_sprite.frame = 0
