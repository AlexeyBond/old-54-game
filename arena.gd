extends Node2D

class_name Arena

@export var start_point: Vector2 = Vector2(100, 100)
@export var interval_seconds: float = .5

const FADE_K: float = 0.8
const FADE_MIN: float = 0.05
const AREA_TO_SCORE: float = 0.001

class DrawableRect extends RefCounted:
	var rect: Rect2
	var color: Color

	func _init(rect: Rect2, color: Color):
		self.rect = rect;
		self.color = color;

	func draw(target: CanvasItem):
		target.draw_rect(self.rect, Color(self.color, self.color.a * 0.1))
		target.draw_rect(self.rect, self.color, false, 1.5)
	
	func fade():
		self.color.a = max(self.color.a * FADE_K, FADE_MIN)

class EffectRect extends DrawableRect:
	var effect_sub_r: int = 0
	var effect_add_y: int = 0
	var effect_add_w: int = 0
	var effect_add_p: int = 0

signal update_current_effects(effects: Array[EffectRect])
signal apply_effects(effects: Array[EffectRect])

var current_point: Vector2
var history: Array[DrawableRect] = []

var current_effects: Array[EffectRect] = []

func _ready():
	current_point = start_point

func get_future_rect() -> Rect2:
	return Rect2(current_point, Vector2.ZERO).expand(get_local_mouse_position())
	
func get_future_rect_drawable() -> DrawableRect:
	return DrawableRect.new(get_future_rect(), Color.WHITE)

func commit():
	var future_rect: DrawableRect = get_future_rect_drawable()
	var effects: Array[EffectRect] = calculate_effects(future_rect.rect)
	apply_effects.emit(effects)

	for hr in history:
		hr.fade()
	history.push_front(future_rect)
	current_point = get_local_mouse_position()
	current_effects.clear()
	update_current_effects.emit(current_effects)

func calculate_effects(future_rect: Rect2) -> Array[EffectRect]:
	var effects: Array[EffectRect] = []
	
	if history.size() > 0:
		var r: Rect2 = history[0].rect.intersection(future_rect.grow(1))
		
		if r.get_area() > 2.0 and (r.size.x <= 1.1 or r.size.y <= 1.1):
			var er: EffectRect = EffectRect.new(r.grow(5), Color.YELLOW)
			er.effect_add_y = int(r.get_area())
			effects.push_back(er)

	for hr in history:
		var r: Rect2 = future_rect.intersection(hr.rect)
		if r.has_area():
			var effect: EffectRect = EffectRect.new(r, Color.RED)
			effect.effect_sub_r = int(r.get_area() * AREA_TO_SCORE)
			effects.push_back(effect)

	for n in self.get_children():
		if n is Effector:
			var er: EffectRect = n.get_effect_rect(future_rect)
			
			if er != null:
				n.set_touched(true)
				effects.push_back(er)
			else:
				n.set_touched(false)

	var future_rect_effect: EffectRect = EffectRect.new(future_rect, Color.WHITE)
	future_rect_effect.effect_add_w = int(future_rect.get_area() * AREA_TO_SCORE)
	effects.push_back(future_rect_effect)

	return effects

func _process(_delta):
	current_effects = calculate_effects(get_future_rect())
	update_current_effects.emit(current_effects)
	queue_redraw()

func _draw():
	for hr in history:
		hr.draw(self)
	
	get_future_rect_drawable().draw(self)

	for er in current_effects:
		er.draw(self)
