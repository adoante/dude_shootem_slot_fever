extends CSGBox3D

@onready var area_3d: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var label: Label = $DoorUI/Label

var unlocking: bool = false
var cost: int = 1000

func _unhandled_input(event: InputEvent) -> void:
	if unlocking and event.is_action_released("unlock"):
		if GameManager.get_money() >= cost:
			SceneManager.goto_story(SceneManager.ScreenState.STORY_3)
		else:
			var money_needed = cost - GameManager.get_money()
			label.text = "Door is locked!\nYou need: " + str(money_needed) + " monies!"
			label.visible = true
			timer.start()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		unlocking = true
		
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		unlocking = false

func _on_timer_timeout() -> void:
	timer.stop()
	label.visible = false
