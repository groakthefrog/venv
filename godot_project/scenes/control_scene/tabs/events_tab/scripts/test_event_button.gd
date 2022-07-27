extends Button

export(Texture) var tex: Texture

func _ready():
	connect("pressed", self, "_on_pressed")

func _on_pressed()->void:
	var event = EventManager.Event.new()
	event.name = "Test Event"
	event.texture = tex
	EventManager.add_event(event)
