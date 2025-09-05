extends StaticBody3D

@onready var animated_sprite_3d: AnimatedSprite3D = $AnimatedSprite3D
@onready var roll_timer: Timer = $RollTimer
@onready var gun_capcity_timer: Timer = $GunCapcityTimer
@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()
@onready var label_timer: Timer = $LabelTimer
@onready var damage_taken_timer: Timer = $DamageTakenTimer
@onready var spin_sfx: AudioStreamPlayer3D = $SpinSFX
@onready var win_sfx: AudioStreamPlayer3D = $WinSFX
@onready var lose_sfx: AudioStreamPlayer3D = $LoseSFX
@onready var slot_machine_ui: CanvasLayer = GameManager.get_slot_machine_ui()

enum Outcomes {
	MONEY_ADD,
	HEALTH_ADD,
	WEAPON_UPGRADE,
	WEAPON_DOWNGRADE,
	DAMAGE_TAKEN_BOOST,
	WEAPON_CAPACITY_DECREASE,
}

@export var health_amount: float = 1.0
@export var money_amount: int = 75
@export var gun_capcity_amount: float = 0.25 
@export var gun_capacity_time: float = 15.0
@export var damage_taken_time: float = 10.0
@export var spin_cost: int = 50
@export var dmg_boost: float = 0.5

@export_group("Slot Machine Weights")
@export var weight_money: float = 3.0
@export var weight_health: float = 5.0
@export var weight_weapon_upgrade: float = 3
@export var weight_weapon_downgrade: float = 0.5
@export var weight_damage_taken: float = 1.0
@export var weight_capacity_decrease: float = 1.0

var rolling: bool = false
var debuff: bool = false
var is_spinning: bool = false 
var can_interact: bool = false

func _ready() -> void:
	gun_capcity_timer.wait_time = gun_capacity_time
	damage_taken_timer.wait_time = damage_taken_time
	rng.randomize()

func _process(_delta: float) -> void:
	if debuff:
		slot_machine_ui.get_node("Pain").visible = true
		slot_machine_ui.get_node("DamageTakenLabel").text = "%d Enemy Damage Boost" % damage_taken_timer.time_left
		slot_machine_ui.get_node("GunCapacityLabel").text  = "%d Gun Capacity Lowered" % gun_capcity_timer.time_left
	else:
		slot_machine_ui.get_node("Pain").visible  = false
		slot_machine_ui.get_node("DamageTakenLabel").text = ""
		slot_machine_ui.get_node("GunCapacityLabel").text  = ""

func _input(event: InputEvent) -> void:
	if not can_interact:
		return
		
	if rolling and not is_spinning and event.is_action_released("action"):
		if GameManager.get_money() >= spin_cost:
			is_spinning = true
			spin_sfx.play()
			rolling = false
			animated_sprite_3d.play("spin")
			slot_machine_ui.get_node("Label").text = "RISK IT\nFOR\nTHE BISCUIT!"
			GameManager.update_money(-spin_cost)
			
			roll_timer.start()
			await roll_timer.timeout
			var outcome = _roll_slot_machine()
			_apply_outcome(outcome)
			spin_sfx.stop()
			is_spinning = false
			rolling = true

func get_weights() -> Dictionary:
	return {
		Outcomes.MONEY_ADD: weight_money,
		Outcomes.HEALTH_ADD: weight_health,
		Outcomes.WEAPON_UPGRADE: weight_weapon_upgrade,
		Outcomes.WEAPON_DOWNGRADE: weight_weapon_downgrade,
		Outcomes.DAMAGE_TAKEN_BOOST: weight_damage_taken,
		Outcomes.WEAPON_CAPACITY_DECREASE: weight_capacity_decrease,
	}

func _roll_slot_machine() -> int:
	var weights = get_weights()

	var total_weight: float = 0.0
	for value in weights.values():
		total_weight += value

	var rand: float = rng.randf_range(0.0, total_weight)
	var cumulative: float = 0.0

	for outcome in weights.keys():
		cumulative += weights[outcome]
		if rand <= cumulative:
			return outcome

	return Outcomes.MONEY_ADD

func _apply_outcome(outcome: int) -> void:
	match outcome:
		Outcomes.MONEY_ADD:
			animated_sprite_3d.play("good")
			slot_machine_ui.get_node("Label").text = "Player\ngets\nmoney!"
			GameManager.update_money(money_amount)
			label_timer.start()
			win_sfx.play()
		Outcomes.HEALTH_ADD:
			animated_sprite_3d.play("good")
			slot_machine_ui.get_node("Label").text = "Player\nheals!"
			GameManager.update_health(health_amount)
			label_timer.start()
			win_sfx.play()
		Outcomes.WEAPON_UPGRADE:
			animated_sprite_3d.play("good")
			upgrade_gun()
			slot_machine_ui.get_node("Label").text = "Player\nweapon\nis\nupgraded!"
			label_timer.start()
			win_sfx.play()
		Outcomes.WEAPON_DOWNGRADE:
			animated_sprite_3d.play("bad")
			downgrade_gun()
			slot_machine_ui.get_node("Label").text = "Player\nweapon\nis\ndowngraded!"
			label_timer.start()
			lose_sfx.play()
		Outcomes.DAMAGE_TAKEN_BOOST:
			animated_sprite_3d.play("bad")
			slot_machine_ui.get_node("Label").text = "Player\ntakes\nmore\ndamage!"
			GameManager.set_damage_boost(dmg_boost)
			get_node("/root/Main/WorldEnvironment").environment = load("res://Resources/sky_2.tres")
			label_timer.start()
			damage_taken_timer.start()
			debuff = true
			lose_sfx.play()
		Outcomes.WEAPON_CAPACITY_DECREASE:
			animated_sprite_3d.play("bad")
			slot_machine_ui.get_node("Label").text = "Weapon\ncapacity\ndecreased!"
			var new_gun_capacity = GameManager.get_gun_capacity() - (GameManager.get_gun_capacity() * gun_capcity_amount)
			GameManager.set_gun_capacity(new_gun_capacity)
			GameManager.set_bullets_left(new_gun_capacity)
			get_node("/root/Main/WorldEnvironment").environment = load("res://Resources/sky_2.tres")
			label_timer.start()
			gun_capcity_timer.start()
			debuff = true
			lose_sfx.play()

func upgrade_gun() -> void:
	var next_state = int(GameManager.get_gun_state()) + 1
	if next_state > GameManager.GunState.MINIGUN:
		next_state = GameManager.GunState.MINIGUN
	GameManager.set_gun_state(next_state)
	print("Upgraded to: ", str(GameManager.get_gun_state()))

func downgrade_gun() -> void:
	var next_state = int(GameManager.get_gun_state()) - 1
	if next_state < GameManager.GunState.PISTOL:
		next_state = GameManager.GunState.PISTOL
	GameManager.set_gun_state(next_state)
	print("Downgraded to: ", str(GameManager.get_gun_state()))

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player_ui = body.get_player_ui()
		player_ui.player_sprite.play("Estatic")
		rolling = true
		can_interact = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		var player_ui = body.get_player_ui()
		player_ui.player_sprite.play("Happy")
		rolling = false
		is_spinning = false
		can_interact = false

func _on_gun_capcity_timer_timeout() -> void:
	gun_capcity_timer.stop()
	GameManager.set_gun_state(GameManager.get_gun_state())
	get_node("/root/Main/WorldEnvironment").environment = load("res://Resources/environment.tres")
	debuff = false

func _on_damage_taken_timer_timeout() -> void:
	damage_taken_timer.stop()
	GameManager.set_damage_boost(0.0)
	get_node("/root/Main/WorldEnvironment").environment = load("res://Resources/environment.tres")
	debuff = false

func _on_label_timer_timeout() -> void:
	label_timer.stop()
	slot_machine_ui.get_node("Label").text = ""
