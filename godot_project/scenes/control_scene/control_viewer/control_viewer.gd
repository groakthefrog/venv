extends ViewportContainer

onready var _viewport: Viewport = Util.A($Viewport as Viewport)

func _ready():
	connect("resized", self, "_on_resized")
	connect("gui_input", self, "_on_viewport_gui_input")
	_viewport.size = rect_size

func _on_resized():

	_viewport.size = rect_size

func _on_viewport_gui_input(event:InputEvent)->void:
	if event is InputEventMouseButton and event.pressed and (event as InputEventMouseButton).button_index == BUTTON_LEFT:
		#Manager.local_viewer
		pass
