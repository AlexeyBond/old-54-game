extends Effector

class_name MulEffector

@export var value: int = 2

func _ready():
	$Label.text = "X%d" % value

func _add_effects(er: Arena.EffectRect):
	er.effect_mul_b = value
