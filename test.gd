extends Node2D

@export var start_point: Vector2 = Vector2(100, 100)

const FADE_K: float = 0.8

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
		self.color.a = max(self.color.a * FADE_K, 0.1)

class EffectRect extends DrawableRect:
	pass

var current_point: Vector2
var history: Array[DrawableRect] = []

var current_effects: Array[EffectRect] = []
var current_future_rect: DrawableRect

func _ready():
	current_point = start_point

func get_future_rect() -> Rect2:
	return Rect2(current_point, Vector2.ZERO).expand(get_local_mouse_position())
	
func get_future_rect_drawable() -> DrawableRect:
	return DrawableRect.new(get_future_rect(), Color.WHITE)

func _unhandled_input(event):
	if not event.is_action_pressed("click"):
		return

	var future_rect: DrawableRect = get_future_rect_drawable()
	var effects: Array[EffectRect] = calculate_effects(future_rect.rect)

	# TODO: Apply effects

	for hr in history:
		hr.fade()
	history.push_front(future_rect)
	current_point = get_local_mouse_position()
	current_effects.clear()

func calculate_effects(future_rect: Rect2) -> Array[EffectRect]:
	var effects: Array[EffectRect] = []
	
	for hr in history:
		var r: Rect2 = future_rect.intersection(hr.rect)
		if r.has_area():
			var effect: EffectRect = EffectRect.new(r, Color.RED)

			# TODO: make effect effective

			effects.push_back(effect)
	
	return effects

func _process(delta):
	current_future_rect = get_future_rect_drawable()
	current_effects = calculate_effects(current_future_rect.rect)
	queue_redraw()

func _draw():
	for hr in history:
		hr.draw(self)
	
	get_future_rect_drawable().draw(self)

	for er in current_effects:
		er.draw(self)
