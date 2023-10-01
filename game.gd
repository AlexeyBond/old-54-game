extends Node

class_name Game

@export var arena: Arena
@export var status_text: RichTextLabel
@export var timer: Timer

@export var timer_enabled: bool = true

var score: int = 0
var ticks: int = 0

var is_stopped: bool = false;

signal started;

func _unhandled_input(event):
	if event.is_action_pressed("click") and (timer != null and timer.is_stopped()) and not self.is_stopped:
		arena.commit()

		if timer_enabled:
			timer.start()
			started.emit()
	elif event.is_action_pressed("reload"):
		get_tree().reload_current_scene()

func total_effect(effects: Array[Arena.EffectRect]) -> Arena.EffectRect:
	var res: Arena.EffectRect = Arena.EffectRect.new(Rect2(Vector2.ZERO, Vector2.ZERO), Color.BLACK)

	for fx in effects:
		res.effect_add_w += fx.effect_add_w
		res.effect_add_y += fx.effect_add_y
		res.effect_sub_r += fx.effect_sub_r
		res.effect_add_p += fx.effect_add_p
		res.effect_mul_b *= fx.effect_mul_b

	return res

func format_status(effects: Array[Arena.EffectRect]):
	var res = "[color=gray]{}[/color]".format([score], "{}")
	
	var total_effect: Arena.EffectRect = total_effect(effects)

	if total_effect.effect_add_w != 0:
		res += " [color=white]%+d[/color]" % total_effect.effect_add_w
	if total_effect.effect_add_y != 0:
		res += " [color=yellow]%+d[/color]" % total_effect.effect_add_y
	if total_effect.effect_add_p != 0:
		res += " [color=ff00ff]%+d[/color]" % total_effect.effect_add_p
	if total_effect.effect_sub_r != 0:
		res += " [color=red]%+d[/color]" % -total_effect.effect_sub_r
	
	if total_effect.effect_mul_b != 1:
		res += " [color=blue]X%d[/color]" % total_effect.effect_mul_b

	return res

signal gained(score: int, delta: int);

func show_delta(delta: int):
	var label: RichTextLabel = $CanvasLayer/delta_label.duplicate()
	label.text = "%+d" % delta
	
	if delta < 0:
		label.text = "[color=red]%s[/color]" % label.text
	
	label.visible = true
	$CanvasLayer.add_child(label)
	
	var tw: Tween = get_tree().create_tween()
	
	tw.parallel().tween_property(label, 'position', Vector2(0, 500), 1.0)
	tw.parallel().tween_property(label, 'modulate', Color(Color.WHITE, 0), 1.0)
	tw.tween_callback(label.queue_free)

func apply_effects(effects: Array[Arena.EffectRect]):
	var total_effect: Arena.EffectRect = total_effect(effects)

	var delta: int = total_effect.effect_add_w + total_effect.effect_add_y - total_effect.effect_sub_r + total_effect.effect_add_p

	delta *= total_effect.effect_mul_b

	score += delta
	gained.emit(score, delta);
	status_text.text = format_status([])
	show_delta(delta)

func update_current_effects(effects: Array[Arena.EffectRect]):
	status_text.text = format_status(effects)

signal tick_done(int)

func tick():
	arena.commit()
	ticks += 1
	tick_done.emit(ticks)

func _ready():
	arena.apply_effects.connect(self.apply_effects)
	arena.update_current_effects.connect(self.update_current_effects)
	timer.timeout.connect(self.tick)

func stop():
	timer.stop()
	is_stopped = true
