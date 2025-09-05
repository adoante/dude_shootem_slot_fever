extends Node

enum ScreenState {
	STORY_1,
	STORY_2,
	STORY_3,
	STORY_4,
	STORY_5,
	START,
	PLAY,
}

# Scene paths (keep them consistent in naming)
const START_SCREEN : String = "res://Scenes/UI/start_screen.tscn"
const PLAY_SCREEN  : String = "res://Scenes/main.tscn"
const STORY_1_CARD : String = "res://Scenes/UI/story_1.tscn"
const STORY_2_CARD : String = "res://Scenes/UI/story_2.tscn"
const STORY_3_CARD : String = "res://Scenes/UI/story_3.tscn"
const STORY_4_CARD : String = "res://Scenes/UI/story_4.tscn"
const STORY_5_CARD : String = "res://Scenes/UI/story_5.tscn"

var prev_scene: ScreenState
var current_scene: ScreenState = ScreenState.START

func _ready() -> void:
	GameManager.get_bgm().play()

func exit_game() -> void:
	get_tree().quit()

func set_current(scene: ScreenState) -> void:
	prev_scene = current_scene
	current_scene = scene

func get_current_scene() -> ScreenState:
	return current_scene

func get_prev_scene() -> ScreenState:
	return prev_scene

func goto_story(scene: ScreenState) -> void:
	set_current(scene)
	
	match scene:
		ScreenState.STORY_1:
			get_tree().change_scene_to_file(STORY_1_CARD)
		ScreenState.STORY_2:
			get_tree().change_scene_to_file(STORY_2_CARD)
		ScreenState.STORY_3:
			get_tree().change_scene_to_file(STORY_3_CARD)
		ScreenState.STORY_4:
			get_tree().change_scene_to_file(STORY_4_CARD)
		ScreenState.STORY_5:
			get_tree().change_scene_to_file(STORY_5_CARD)

func goto_next() -> void:
	match current_scene:
		ScreenState.START:
			goto_story(ScreenState.STORY_1)
		ScreenState.STORY_1:
			goto_story(ScreenState.STORY_2)
		ScreenState.STORY_2:
			goto_play()
		ScreenState.STORY_3:
			GameManager.get_bgm().stream_paused = false
			goto_story(ScreenState.STORY_4)
		ScreenState.STORY_4:
			goto_story(ScreenState.STORY_5)
		ScreenState.STORY_5:
			goto_start()

func goto_start() -> void:
	set_current(ScreenState.START)
	get_tree().change_scene_to_file(START_SCREEN)
	
func goto_play() -> void:
	GameManager.get_bgm().stream_paused = true
	set_current(ScreenState.PLAY)
	get_tree().change_scene_to_file(PLAY_SCREEN)
