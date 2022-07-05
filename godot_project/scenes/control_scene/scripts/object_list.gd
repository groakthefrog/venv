extends ItemList

func _ready()->void:
	connect("object_added", self, "_on_object_added")

func _on_object_added(new_object:Node)->void:
	add_item(new_object.name)
