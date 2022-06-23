extends ViewportContainer

onready var _viewport: Viewport = Util.A($Viewport as Viewport)

func _ready():
	connect("resized", self, "_on_resized")
	_viewport.size = rect_size

func _on_resized():
	_viewport.size = rect_size