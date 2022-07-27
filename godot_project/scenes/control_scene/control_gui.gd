extends VBoxContainer

const _TEST_OBJECT: PackedScene = preload('res://test_object.tscn')

export(NodePath) onready var _file_dialog = Util.A(get_node(_file_dialog) as FileDialog)
export(NodePath) onready var _add_menu_button = Util.A(get_node(_add_menu_button) as MenuButton)
onready var _add_popup_menu: PopupMenu = _add_menu_button.get_popup()

func _ready():
	_add_popup_menu.connect("index_pressed", self, "_on_add_menu_button_pressed")
	_file_dialog.connect("file_selected", self, "_on_file_selected")


func _on_add_menu_button_pressed(idx:int)->void:
	match _add_popup_menu.get_item_text(idx):
		"New Puppet":
			_add_new_puppet_from_file()
		"New Object":
			_add_test_object()


func _add_new_puppet_from_file()->void:
	(_file_dialog as FileDialog).show()


func _on_file_selected(file:String)->void:
	var vrm: PackedScene = load(file)
	var instance := vrm.instance()
	Venv._add_object(instance) # @todo remove this


func _add_test_object()->void:
	var instance := _TEST_OBJECT.instance()
	Venv._add_object(instance) # @todo remove this
