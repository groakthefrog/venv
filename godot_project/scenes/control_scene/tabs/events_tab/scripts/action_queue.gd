extends ItemList

var _event: Reference

func _ready():
	pass

func refresh(event:Reference= null)->void:
	if event:
		_event = event
	clear()
	for action in _event.action_queue:
		add_item(action.name, action.texture)
