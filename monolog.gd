extends Control

@export var text: Array[String] = []

@export var speed: float = 50.0

@export_file("*.tscn") var next_scene: String

signal over;

var current_str: int = -1

var tween: Tween = null

func start_next_str():
	current_str += 1

	if current_str >= text.size():
		over.emit()
		
		if not next_scene.is_empty():
			get_tree().change_scene_to_file(next_scene)
		return
	
	var tb: RichTextLabel = %text_box
	tb.text = text[current_str]
	tb.visible_characters = 0
	
	var l: int = text[current_str].length()

	tween = get_tree().create_tween()
	tween.tween_property(tb, "visible_characters", l, l / speed)

func _input(event):
	if event.is_action_pressed("click"):
		if tween != null and tween.is_running():
			tween.stop()
			(%text_box).visible_ratio = 1.0
		else:
			start_next_str()

func _ready():
	start_next_str()
