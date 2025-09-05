extends CanvasLayer

@onready var click_sfx: AudioStreamPlayer2D = $ClickSFX
@onready var continue_animation_player: AnimationPlayer = $ContinueButton/AnimationPlayer

func _on_continue_button_pressed() -> void:
	SceneManager.goto_next()
			
func _on_continue_button_mouse_entered() -> void:
	click_sfx.play()
	continue_animation_player.play("expand_tilt_left_then_right")

func _on_continue_button_mouse_exited() -> void:
	continue_animation_player.play("RESET")
