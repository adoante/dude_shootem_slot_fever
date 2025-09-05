extends CanvasLayer

@onready var click_sfx: AudioStreamPlayer2D = $ClickSFX

@onready var start_button: Button = $StartButton
@onready var exit_button: Button = $ExitButton

@onready var start_animation_player: AnimationPlayer = $StartButton/AnimationPlayer
@onready var exit_animation_player: AnimationPlayer = $ExitButton/AnimationPlayer

# START
func _on_start_button_pressed() -> void:
	SceneManager.goto_story(SceneManager.ScreenState.STORY_1)

func _on_start_button_mouse_entered() -> void:
	click_sfx.play()
	start_animation_player.play("expand_tilt_left_then_right")
	
func _on_start_button_mouse_exited() -> void:
	start_animation_player.play("RESET")

# EXIT
func _on_exit_button_pressed() -> void:
	SceneManager.exit_game()

func _on_exit_button_mouse_entered() -> void:
	click_sfx.play()
	exit_animation_player.play("expand_tilt_left_then_right")

func _on_exit_button_mouse_exited() -> void:
	exit_animation_player.play("RESET")
