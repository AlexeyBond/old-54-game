extends Node

class_name Game

@export var arena: Arena
@export var status_text: RichTextLabel
@export var timer: Timer

var score: int = 0

func _unhandled_input(event):
	if event.is_action_pressed("click") and timer.is_stopped():
		arena.commit()
		timer.start()

func total_effect(effects: Array[Arena.EffectRect]) -> Arena.EffectRect:
	var res: Arena.EffectRect = Arena.EffectRect.new(Rect2(Vector2.ZERO, Vector2.ZERO), Color.BLACK)

	for fx in effects:
		res.effect_add_w += fx.effect_add_w
		res.effect_add_y += fx.effect_add_y
		res.effect_sub_r += fx.effect_sub_r

	return res

func format_status(effects: Array[Arena.EffectRect]):
	var res = "[color=gray]{}[/color]".format([score], "{}")
	
	var total_effect: Arena.EffectRect = total_effect(effects)

	if total_effect.effect_add_w > 0:
		res += " [color=white]+{}[/color]".format([total_effect.effect_add_w], "{}")
	if total_effect.effect_add_y > 0:
		res += " [color=yellow]+{}[/color]".format([total_effect.effect_add_y], "{}")
	if total_effect.effect_sub_r > 0:
		res += " [color=red]-{}[/color]".format([total_effect.effect_sub_r], "{}")

	return res

func apply_effects(effects: Array[Arena.EffectRect]):
	var total_effect: Arena.EffectRect = total_effect(effects)

	var delta: float = total_effect.effect_add_w + total_effect.effect_add_y - total_effect.effect_sub_r

	score += delta
	status_text.text = format_status([])

func update_current_effects(effects: Array[Arena.EffectRect]):
	status_text.text = format_status(effects)

func tick():
	arena.commit()

func _ready():
	arena.apply_effects.connect(self.apply_effects)
	arena.update_current_effects.connect(self.update_current_effects)
	timer.timeout.connect(self.tick)
