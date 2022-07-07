extends VBoxContainer

export(NodePath) onready var _tree = Util.A(get_node(_tree) as Tree)

func _ready():
	_tree.connect("item_selected", self, "_on_tree_item_selected")

func _on_tree_item_selected():
	for c in get_children():
		remove_child(c)
	var item := (_tree as Tree).get_selected()
	var node: Node = item.get_metadata(0)

	for prop in node.get_property_list():

		var l := Label.new()
		if prop.usage & PROPERTY_USAGE_EDITOR:
			l.text = str(prop.name)
			add_child(l)