extends Node
class_name ControllerManager
var _selected_objects := []

signal selected_objects_changed()

func set_selected_objects(objs:Array)->void:
	_selected_objects = objs

#func add_selected_obj