extends Effector

class_name AddEffector

@export var value: int = 1000

func _ready():
	if abs(value) >= 1000000 and value % 1000000 == 0:
		$Label.text = "%+dM" % (value / 1000000)
	elif abs(value) >= 1000 and value % 1000 == 0:
		$Label.text = "%+dK" % (value / 1000)
	else:
		$Label.text = "%+d" % value

func _add_effects(er: Arena.EffectRect):
	er.effect_add_p = value
