extends CanvasModulate

func _ready():
	color = Color(0.3, 0.3, 0.8)  # Синеватый оттенок для лаборатории

# Для мигания аварийного света
func _process(delta):
	# Пульсация красного аварийного света
	var pulse = sin(OS.get_ticks_msec() * 0.01) * 0.3 + 0.7
	color = Color(0.3, 0.3 * pulse, 0.8 * pulse)
