extends ItemList

export(NodePath) onready var action_queue_list = get_node(action_queue_list) as ItemList

onready var _event_manager: Node = EventManager

func _ready():
	_event_manager.connect("events_changed", self, "_refresh")
	connect("item_selected", self, "_on_item_selected")

func _refresh()->void:
	clear()
	for event in _event_manager.get_events():
		add_item(event.name, event.texture)

	# @todo reselect event if still exists after refresh

func _on_item_selected(index:int)->void:
	var event = _event_manager.get_event(index)
	assert(event)
	action_queue_list.refresh(event)
