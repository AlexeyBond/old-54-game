extends Node2D

class_name Effector

@export var half_size: float = 25
@export var color: Color = Color.WHITE

var alpha_k: float = 0.5
var touched: bool = false

func set_touched(touched: bool):
	if self.touched == touched:
		return
	
	self.touched = touched
	
	if touched:
		alpha_k = 1.0
	else:
		alpha_k = 0.5
	
	queue_redraw()

func _add_effects(er: Arena.EffectRect):
	pass

func get_effect_rect(future_rect: Rect2) -> Arena.EffectRect:
	var own_rect: Rect2 = Rect2(self.position - Vector2.ONE * half_size, Vector2.ONE * half_size * 2.0)
	var r: Rect2 = future_rect.intersection(own_rect)

	if not r.has_area():
		return null

	var er: Arena.EffectRect = Arena.EffectRect.new(r, color)
	_add_effects(er)
	return er

func _draw():
	draw_rect(
		Rect2(Vector2(-half_size, -half_size), Vector2(half_size, half_size) * 2),
		Color(color, color.a * 0.5 * alpha_k)
	)
	draw_rect(
		Rect2(Vector2(-half_size, -half_size), Vector2(half_size, half_size) * 2),
		Color(color, color.a * alpha_k),
		false, 1.0,
	)
