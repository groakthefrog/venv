extends Tree

export var show_all:bool = false

func _ready()->void:
	Venv.connect("venv_changed", self, "update_tree")
	get_tree().connect("tree_changed", self, "_delay_update_tree")
	update_tree()

func _delay_update_tree()->void:
	call_deferred("update_tree")

func update_tree()->void:
	clear()

	var parent_item := create_item() # create root
	var node_layers: Array = [Venv.local_scene.get_children()]
	node_layers[0].invert()

	while node_layers:
		var layer: Array = node_layers.back()
		if layer:
			var cur_node: Node = layer.pop_back()
			var cur_item: TreeItem = null
			if show_all or cur_node.is_in_group(Constants.VENV_OBJECT_GROUP_NAME):
				cur_item = create_item(parent_item)
				cur_item.set_text(0, cur_node.name)
				cur_item.set_metadata(0, cur_node)
			if cur_node.get_child_count():
				if cur_item:
					parent_item = cur_item
				var new_layer := cur_node.get_children()
				new_layer.invert()
				node_layers.push_back(new_layer)
		else:
			node_layers.pop_back()
			if parent_item != get_root():
				parent_item = parent_item.get_parent()

func _on_show_all_buttoned_toggled(button_pressed:bool):
	if show_all != button_pressed:
		show_all = button_pressed
		update_tree()